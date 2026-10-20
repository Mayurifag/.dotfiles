"""Offline regression check; use the downloader's Python interpreter."""

import os
import tempfile
from pathlib import Path

from download_telegram import build_config, new_destination, parse_chat_id


source = {"max_messages": 3, "chats": [{
    "chat_id": -100, "last_read_message_id": 99, "ids_to_retry": [7],
    "max_messages": 2, "max_concurrent_downloads": 4,
}]}
target = build_config(source, -100, Path("output"), None)["chats"][0]
assert target["last_read_message_id"] == 0 and target["ids_to_retry"] == []
assert target["max_messages"] is None and target["start_date"] is None
assert len(target["media_types"]) == 6
assert target["max_concurrent_downloads"] == 4
assert source["chats"][0]["last_read_message_id"] == 99
assert build_config(source, -100, Path("output"), 5)["chats"][0]["max_messages"] == 5
assert parse_chat_id("-100") == -100 and parse_chat_id("@channel") == "@channel"
try:
    parse_chat_id("x/../../outside")
except ValueError:
    pass
else:
    raise AssertionError("Path traversal accepted")

old_cwd = Path.cwd()
with tempfile.TemporaryDirectory(prefix="tgd-check-") as directory:
    try:
        os.chdir(directory)
        assert new_destination("-100").is_dir()
        assert new_destination("-100").name == "telegram-media-100-2"
    finally:
        os.chdir(old_cwd)
print("Offline Telegram runner checks passed")
