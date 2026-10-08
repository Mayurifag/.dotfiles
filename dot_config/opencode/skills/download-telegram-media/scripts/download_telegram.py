"""Run user's Telegram Media Downloader with one temporary chat config."""

from __future__ import annotations

import argparse
import importlib
import os
import re
import sys
import tempfile
from pathlib import Path
from typing import Any

import yaml


DEFAULT_APP_DIR = Path.home() / "Code" / "telegram_media_downloader"


def parse_chat_id(value: str) -> int | str:
    if not re.fullmatch(r"-?[0-9]+|@?[A-Za-z][A-Za-z0-9_]*", value):
        raise ValueError("chat ID must be an integer or Telegram username")
    try:
        return int(value)
    except ValueError:
        return value


def new_destination(chat_id: str) -> Path:
    parse_chat_id(chat_id)
    name = f"telegram-media-{chat_id.lstrip('-')}"
    candidate = Path.cwd() / name
    suffix = 2
    while True:
        try:
            candidate.mkdir()
            return candidate
        except FileExistsError:
            candidate = Path.cwd() / f"{name}-{suffix}"
            suffix += 1


def build_config(source: dict[str, Any], chat_id: int | str, destination: Path, limit: int | None) -> dict[str, Any]:
    existing = next(
        (
            chat
            for chat in source.get("chats", [])
            if str(chat.get("chat_id")) == str(chat_id)
        ),
        None,
    )
    target = existing.copy() if existing else {}
    target["chat_id"] = chat_id
    target["download_directory"] = str(destination)
    target.update(
        last_read_message_id=0,
        ids_to_retry=[],
        max_messages=limit,
        start_date=None,
        end_date=None,
        media_types=["photo", "video", "audio", "voice", "video_note", "document"],
        file_formats={kind: ["all"] for kind in ("audio", "video", "document")},
    )

    config = source.copy()
    config.pop("chat_id", None)
    config.pop("last_read_message_id", None)
    config.pop("ids_to_retry", None)
    config["chats"] = [target]
    config["parallel_chats"] = False
    return config


def run(app_dir: Path, chat_id_text: str, destination: Path | None, limit: int | None) -> None:
    app_dir = app_dir.expanduser().resolve()
    source_path = app_dir / "config.yaml"
    if not source_path.is_file():
        raise FileNotFoundError(f"Missing app config: {source_path}")

    chat_id = parse_chat_id(chat_id_text)
    with source_path.open(encoding="utf-8") as source_file:
        source = yaml.safe_load(source_file)
    if not isinstance(source, dict):
        raise ValueError("App config must contain a YAML mapping")
    chats = source.get("chats", [])
    if not isinstance(chats, list) or any(not isinstance(chat, dict) for chat in chats):
        raise ValueError("App chats must contain a list of YAML mappings")
    if limit is not None and limit < 1:
        raise ValueError("--limit must be positive")

    destination = (destination or new_destination(chat_id_text)).expanduser().resolve()
    destination.mkdir(parents=True, exist_ok=True)

    config = build_config(source, chat_id, destination, limit)
    old_cwd = Path.cwd()
    old_path = sys.path.copy()
    sys.path.insert(0, str(app_dir))
    try:
        os.chdir(app_dir)
        config_manager = importlib.import_module("config_manager")
        media_downloader = importlib.import_module("media_downloader")
        old_config_path = config_manager.CONFIG_PATH
        try:
            with tempfile.TemporaryDirectory(prefix="telegram-media-") as temp_dir:
                temp_config = Path(temp_dir) / "config.yaml"
                with temp_config.open("w", encoding="utf-8") as config_file:
                    yaml.safe_dump(config, config_file, sort_keys=False)
                setattr(config_manager, "CONFIG_PATH", str(temp_config))
                media_downloader.main()
                failed = len(set(media_downloader.FAILED_IDS.get(chat_id, [])))
                if failed:
                    raise RuntimeError(f"{failed} media downloads failed; saved files remain in {destination}")
                if not media_downloader.DOWNLOADED_IDS.get(chat_id):
                    raise RuntimeError(f"No media downloaded to {destination}")
        finally:
            setattr(config_manager, "CONFIG_PATH", old_config_path)
    finally:
        os.chdir(old_cwd)
        sys.path[:] = old_path


def main() -> None:
    parser = argparse.ArgumentParser(description="Download one Telegram chat with the configured downloader.")
    parser.add_argument("chat_id", nargs="?", help="Telegram chat or channel ID")
    parser.add_argument("--chat-id", dest="chat_id_option", help="Telegram chat or channel ID")
    parser.add_argument("--destination", type=Path, help="Download directory")
    parser.add_argument("--limit", type=int, help="Maximum number of media items")
    parser.add_argument("--app-dir", type=Path, default=DEFAULT_APP_DIR, help="Telegram downloader directory")
    args = parser.parse_args()
    chat_id = args.chat_id_option or args.chat_id
    if not chat_id:
        parser.error("a chat ID is required")
    if args.chat_id_option and args.chat_id and args.chat_id_option != args.chat_id:
        parser.error("use either positional chat ID or --chat-id, not both")
    if args.limit is not None and args.limit < 1:
        parser.error("--limit must be positive")
    try:
        run(args.app_dir, chat_id, args.destination, args.limit)
    except yaml.YAMLError:
        parser.exit(1, "Invalid app YAML config\n")
    except (OSError, ValueError, RuntimeError) as error:
        parser.exit(1, f"{error}\n")


if __name__ == "__main__":
    main()
