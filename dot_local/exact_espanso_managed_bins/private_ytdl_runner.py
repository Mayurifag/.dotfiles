import os
import subprocess
import tempfile
import time

OUTPUT_TEMPLATE = "%(title)s.%(ext)s"
SPONSORBLOCK_REMOVE = "sponsor,selfpromo,interaction,intro,outro,preview,music_offtopic"

COMMON_ARGS = [
    "-o",
    OUTPUT_TEMPLATE,
    "--embed-thumbnail",
    "--embed-chapters",
    "--embed-metadata",
    "--concurrent-fragments",
    "3",
]

LOCK_DIR = os.path.join(tempfile.gettempdir(), "uv-yt-dlp-update.lock")

HELIUM_PROFILE_PATHS = [
    "~/AppData/Local/Helium/User Data/Default",
    "~/AppData/Local/Helium/Default",
    "~/Library/Application Support/Helium/Default",
    "~/.config/helium/Default",
    "~/.config/Helium/Default",
]


def helium_cookie_args():
    for path in HELIUM_PROFILE_PATHS:
        profile = os.path.expanduser(path)
        if os.path.isdir(profile):
            return ["--cookies-from-browser", f"chromium:{profile}"]
    return []


def update_ytdlp():
    while True:
        try:
            os.mkdir(LOCK_DIR)
            break
        except FileExistsError:
            time.sleep(0.2)

    try:
        subprocess.run(
            [
                "uv",
                "tool",
                "install",
                "--force",
                "--prerelease",
                "allow",
                "--upgrade",
                "yt-dlp",
            ],
            check=True,
        )
    finally:
        os.rmdir(LOCK_DIR)


def run_ytdlp(args):
    update_ytdlp()
    bin_dir = subprocess.check_output(["uv", "tool", "dir", "--bin"], text=True).strip()
    exe = "yt-dlp.exe" if os.name == "nt" else "yt-dlp"
    return subprocess.run(
        [os.path.join(bin_dir, exe), *helium_cookie_args(), *args]
    ).returncode


def run_gallery_dl(args):
    return subprocess.run(["gallery-dl", *helium_cookie_args(), *args]).returncode
