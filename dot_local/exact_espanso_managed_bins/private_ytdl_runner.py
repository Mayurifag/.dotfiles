import os
import subprocess
import tempfile

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
    subprocess.run(
        [
            "uv",
            "tool",
            "install",
            "--force",
            "--with",
            "curl-cffi",
            "--prerelease",
            "allow",
            "--upgrade",
            "yt-dlp",
        ],
        check=True,
    )


def run_ytdlp(args, *, use_temp_downloads=False):
    update_ytdlp()
    bin_dir = subprocess.check_output(["uv", "tool", "dir", "--bin"], text=True).strip()
    exe = "yt-dlp.exe" if os.name == "nt" else "yt-dlp"
    command = [os.path.join(bin_dir, exe), *helium_cookie_args()]

    if use_temp_downloads:
        cache_dir = os.path.expanduser(os.environ.get("XDG_CACHE_HOME", "~/.cache"))
        staging_parent = os.path.join(cache_dir, "yt-downloads")
        os.makedirs(staging_parent, exist_ok=True)
        with tempfile.TemporaryDirectory(
            prefix="download-", dir=staging_parent
        ) as temp_dir:
            return subprocess.run(
                [*command, "--paths", f"temp:{temp_dir}", *args]
            ).returncode

    return subprocess.run([*command, *args]).returncode


def run_gallery_dl(args):
    return subprocess.run(["gallery-dl", *helium_cookie_args(), *args]).returncode
