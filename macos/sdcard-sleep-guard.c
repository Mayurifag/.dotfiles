#include <DiskArbitration/DiskArbitration.h>
#include <IOKit/IOMessage.h>
#include <IOKit/pwr_mgt/IOPMLib.h>
#include <dispatch/dispatch.h>
#include <errno.h>
#include <fcntl.h>
#include <os/log.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <sys/mount.h>
#include <unistd.h>

static const char *volume_path;
static io_connect_t power_connection;
static IOPMAssertionID idle_assertion;
static bool flush_in_progress;

static bool matches_volume(const struct statfs *mount) {
    return (mount->f_flags & MNT_LOCAL) && !(mount->f_flags & MNT_RDONLY) &&
           strcmp(mount->f_mntonname, volume_path) == 0;
}

static bool mounted(void) {
    struct statfs *mounts;
    int count = getmntinfo(&mounts, MNT_NOWAIT);
    for (int i = 0; i < count; i++) {
        if (matches_volume(&mounts[i])) {
            return true;
        }
    }
    return false;
}

static void update_assertion(void) {
    bool writable = mounted();
    if (writable && idle_assertion == kIOPMNullAssertionID) {
        IOReturn result = IOPMAssertionCreateWithName(
            kIOPMAssertPreventUserIdleSystemSleep, kIOPMAssertionLevelOn,
            CFSTR("Protect writable sdcard volume"), &idle_assertion);
        if (result != kIOReturnSuccess) {
            os_log_error(OS_LOG_DEFAULT, "Cannot create sdcard idle-sleep assertion: %#x", result);
        }
    } else if (!writable && idle_assertion != kIOPMNullAssertionID) {
        IOReturn result = IOPMAssertionRelease(idle_assertion);
        if (result == kIOReturnSuccess) {
            idle_assertion = kIOPMNullAssertionID;
        } else {
            os_log_error(OS_LOG_DEFAULT, "Cannot release sdcard idle-sleep assertion: %#x", result);
        }
    }
}

static void disk_changed(DADiskRef disk __unused, void *context __unused) {
    update_assertion();
}

static void volume_path_changed(DADiskRef disk, CFArrayRef keys __unused, void *context) {
    disk_changed(disk, context);
}

static void flush_volume(void) {
    int fd = open(volume_path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC);
    if (fd == -1) {
        if (errno != ENOENT) {
            os_log_error(OS_LOG_DEFAULT, "Cannot open sdcard to flush it: %{darwin.errno}d", errno);
        }
        return;
    }
    struct statfs mount;
    if (fstatfs(fd, &mount) == -1 ||
        (matches_volume(&mount) && fsync_volume_np(fd, SYNC_VOLUME_WAIT | SYNC_VOLUME_FULLSYNC) != 0)) {
        os_log_error(OS_LOG_DEFAULT, "Cannot flush sdcard before sleep: %{darwin.errno}d", errno);
    }
    close(fd);
}

static void power_changed(void *context __unused, io_service_t service __unused,
                          natural_t message, void *argument) {
    long token = (long)(intptr_t)argument;
    switch (message) {
        case kIOMessageCanSystemSleep:
            if (mounted()) {
                IOCancelPowerChange(power_connection, token);
            } else {
                IOAllowPowerChange(power_connection, token);
            }
            break;
        case kIOMessageSystemWillSleep: {
            if (!mounted() || flush_in_progress) {
                IOAllowPowerChange(power_connection, token);
                break;
            }
            flush_in_progress = true;
            __block bool acknowledged = false;
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                flush_volume();
                dispatch_async(dispatch_get_main_queue(), ^{
                    flush_in_progress = false;
                    if (!acknowledged) {
                        IOAllowPowerChange(power_connection, token);
                        acknowledged = true;
                    }
                });
            });
            // Forced sleep cannot be vetoed. Do not hold it if the card stops responding.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if (!acknowledged) {
                    os_log_error(OS_LOG_DEFAULT, "sdcard flush did not finish before the sleep deadline");
                    IOAllowPowerChange(power_connection, token);
                    acknowledged = true;
                }
            });
            break;
        }
        case kIOMessageSystemHasPoweredOn:
            update_assertion();
            break;
    }
}

int main(int argc, const char *argv[]) {
    if (argc != 2 || argv[1][0] != '/') {
        return 2;
    }
    volume_path = argv[1];

    DASessionRef disks = DASessionCreate(kCFAllocatorDefault);
    IONotificationPortRef power_port;
    io_object_t notifier;
    power_connection = IORegisterForSystemPower(NULL, &power_port, power_changed, &notifier);
    if (disks == NULL || power_connection == IO_OBJECT_NULL) {
        os_log_error(OS_LOG_DEFAULT, "Cannot subscribe to disk and power notifications");
        return 1;
    }
    IONotificationPortSetDispatchQueue(power_port, dispatch_get_main_queue());
    DARegisterDiskAppearedCallback(disks, NULL, disk_changed, NULL);
    DARegisterDiskDisappearedCallback(disks, NULL, disk_changed, NULL);
    DARegisterDiskDescriptionChangedCallback(disks, NULL, kDADiskDescriptionWatchVolumePath,
                                             volume_path_changed, NULL);
    DASessionSetDispatchQueue(disks, dispatch_get_main_queue());
    update_assertion();
    dispatch_main();
}
