#!/usr/bin/env python3
"""Remove GSD state and the old OpenCode skills after installing shared skills."""

import os
import shutil
import stat
import sys
from pathlib import Path


if os.name == "nt" and sys.version_info < (3, 8):
    raise RuntimeError("Python 3.8+ is required to safely remove Windows junctions")


def remove_readonly(function, target, exc_info):
    error = exc_info[1]
    entry = os.lstat(target)
    attributes = getattr(entry, "st_file_attributes", 0)
    if (
        os.name != "nt"
        or not isinstance(error, PermissionError)
        or not stat.S_ISREG(entry.st_mode)
        or not attributes & stat.FILE_ATTRIBUTE_READONLY
        or attributes & stat.FILE_ATTRIBUTE_REPARSE_POINT
    ):
        raise error
    os.chmod(target, stat.S_IWRITE)
    function(target)


destination = Path(os.environ["CHEZMOI_DEST_DIR"])
for path in (destination / ".config/opencode/skills", destination / ".gsd"):
    try:
        entry = path.lstat()
    except FileNotFoundError:
        continue
    if path.is_symlink():
        path.unlink()
    elif getattr(entry, "st_file_attributes", 0) & getattr(
        stat, "FILE_ATTRIBUTE_REPARSE_POINT", 0
    ):
        if entry.st_file_attributes & stat.FILE_ATTRIBUTE_DIRECTORY:
            path.rmdir()
        else:
            path.unlink()
    elif path.is_dir():
        shutil.rmtree(path, onerror=remove_readonly)
    else:
        path.unlink()
    print(f"[chezmoi] Removed {path}")
