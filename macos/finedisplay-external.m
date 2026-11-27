#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <os/log.h>

static NSString *const bundle_id = @"co.nousworks.finedisplay";
static BOOL launching;

enum display_state { DisplayUnknown, DisplayInternalOnly, DisplayExternal };

static enum display_state current_display_state(void) {
    uint32_t count = 0;
    CGError error = CGGetOnlineDisplayList(0, NULL, &count);
    if (error == kCGErrorSuccess && count > 0) {
        CGDirectDisplayID displays[count];
        error = CGGetOnlineDisplayList(count, displays, &count);
        if (error == kCGErrorSuccess) {
            for (uint32_t i = 0; i < count; i++) {
                if (!CGDisplayIsBuiltin(displays[i])) {
                    return DisplayExternal;
                }
            }
        }
    }
    if (error != kCGErrorSuccess) {
        os_log_error(OS_LOG_DEFAULT, "Cannot list online displays: %d", error);
        return DisplayUnknown;
    }
    return DisplayInternalOnly;
}

static void quit_apps(NSArray<NSRunningApplication *> *apps) {
    for (NSRunningApplication *app in apps) {
        if (![app terminate] && !app.terminated) {
            os_log_error(OS_LOG_DEFAULT, "Cannot quit FineDisplay (PID %d)", app.processIdentifier);
        }
    }
}

static void update_app(BOOL allow_launch) {
    NSArray<NSRunningApplication *> *apps =
        [NSRunningApplication runningApplicationsWithBundleIdentifier:bundle_id];
    if (!allow_launch && apps.count == 0) {
        return;
    }
    enum display_state displays = current_display_state();
    if (displays == DisplayUnknown) {
        return;
    }
    if (displays == DisplayInternalOnly) {
        quit_apps(apps);
        return;
    }
    if (!allow_launch || launching || apps.count > 0) {
        return;
    }

    NSWorkspace *workspace = NSWorkspace.sharedWorkspace;
    NSURL *url = [workspace URLForApplicationWithBundleIdentifier:bundle_id];
    if (!url) {
        return;
    }

    NSWorkspaceOpenConfiguration *configuration = [NSWorkspaceOpenConfiguration configuration];
    configuration.activates = NO;
    launching = YES;
    [workspace openApplicationAtURL:url configuration:configuration
                  completionHandler:^(NSRunningApplication *app, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            launching = NO;
            if (error) {
                os_log_error(OS_LOG_DEFAULT, "Cannot open FineDisplay: %{public}@", error);
            } else if (app && current_display_state() == DisplayInternalOnly) {
                quit_apps(@[app]);
            }
        });
    }];
}

static void display_changed(CGDirectDisplayID display __unused,
                            CGDisplayChangeSummaryFlags flags, void *context __unused) {
    if (!(flags & kCGDisplayBeginConfigurationFlag)) {
        dispatch_async(dispatch_get_main_queue(), ^{ update_app(YES); });
    }
}

@interface FineDisplayObserver : NSObject
@end

@implementation FineDisplayObserver
// Workspace launch notifications omit menu bar apps marked LSUIElement.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                       change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{ update_app(NO); });
}
@end

int main(void) {
    @autoreleasepool {
        [NSApplication sharedApplication];
        [NSApp setActivationPolicy:NSApplicationActivationPolicyProhibited];
        CGError error = CGDisplayRegisterReconfigurationCallback(display_changed, NULL);
        if (error != kCGErrorSuccess) {
            os_log_error(OS_LOG_DEFAULT, "Cannot watch display changes: %d", error);
            return 1;
        }

        NSWorkspace *workspace = NSWorkspace.sharedWorkspace;
        FineDisplayObserver *observer = [FineDisplayObserver new];
        [workspace addObserver:observer forKeyPath:@"runningApplications" options:0 context:NULL];
        [workspace.notificationCenter addObserverForName:NSWorkspaceDidWakeNotification
                                                 object:nil queue:NSOperationQueue.mainQueue
                                             usingBlock:^(NSNotification *note __unused) { update_app(YES); }];
        update_app(YES);
        [NSApp run];
        [workspace removeObserver:observer forKeyPath:@"runningApplications"];
    }
    return 0;
}
