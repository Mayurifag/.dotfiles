#!/usr/bin/env python3
"""Inspect and safely advance machine repositories, retaining follow-up state."""

import argparse
import concurrent.futures
import contextlib
import errno
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import unicodedata
from pathlib import Path


def state_dir():
    return Path.home() / ".local/state/sync-machine"


def opencode_executable():
    if os.name == "nt":
        mise = shutil.which("mise.exe")
        if not mise:
            raise ValueError("mise.exe was not found in PATH")
        result = subprocess.run(
            [mise, "which", "--cd", str(Path.home()), "opencode"],
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=20,
            check=False,
        )
        paths = result.stdout.splitlines()
        if result.returncode or len(paths) != 1:
            raise ValueError("cannot resolve the mise-managed OpenCode executable")
        executable = paths[0]
    else:
        executable = shutil.which("opencode")
    if not executable:
        raise ValueError("opencode was not found in PATH")
    path = Path(executable)
    if os.name == "nt" and path.suffix.lower() in (".cmd", ".bat"):
        native = (
            path.parent / "node_modules" / "@opencode" / "cli" / "bin" / "opencode.exe"
        )
        if not native.is_file():
            raise ValueError(
                "unsupported OpenCode batch wrapper; use a native opencode.exe"
            )
        return str(native)
    if os.name == "nt" and (path.suffix.lower() != ".exe" or not path.is_file()):
        raise ValueError("OpenCode must resolve to a native executable")
    return executable


@contextlib.contextmanager
def locked(path, blocking=True):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a+b") as handle:
        if handle.seek(0, os.SEEK_END) == 0:
            handle.write(b"0")
            handle.flush()
        handle.seek(0)
        try:
            if os.name == "nt":
                import msvcrt

                msvcrt.locking(
                    handle.fileno(), msvcrt.LK_LOCK if blocking else msvcrt.LK_NBLCK, 1
                )
            else:
                import fcntl

                fcntl.flock(
                    handle.fileno(), fcntl.LOCK_EX | (0 if blocking else fcntl.LOCK_NB)
                )
        except OSError as error:
            raise ValueError(f"another sync operation holds {path.name}") from error
        try:
            yield handle
        finally:
            handle.seek(0)
            if os.name == "nt":
                msvcrt.locking(handle.fileno(), msvcrt.LK_UNLCK, 1)
            else:
                fcntl.flock(handle.fileno(), fcntl.LOCK_UN)


def session_kind(directory):
    path = directory / "session.lock"
    if not path.exists():
        return None
    try:
        with locked(path, blocking=False):
            return None
    except ValueError:
        with path.open("rb") as handle:
            handle.seek(1)
            return handle.read(32)


def git(repo, *args, check=True, timeout=15, input=None, binary=False):
    env = os.environ.copy()
    env.update(GIT_TERMINAL_PROMPT="0", GIT_OPTIONAL_LOCKS="0", GIT_NO_LAZY_FETCH="1")
    result = subprocess.run(
        [
            "git",
            "-C",
            str(repo),
            "-c",
            "core.fsmonitor=false",
            "-c",
            "submodule.recurse=false",
            "-c",
            "maintenance.auto=false",
            *args,
        ],
        capture_output=True,
        input=input,
        text=not binary,
        encoding=None if binary else "utf-8",
        errors=None if binary else "replace",
        timeout=timeout,
        env=env,
        check=False,
    )
    if check and result.returncode:
        raise ValueError(f"git {args[0]} failed (exit {result.returncode})")
    return result


def repository(path):
    return Path(git(path, "rev-parse", "--show-toplevel").stdout.strip()).resolve()


def source_dir():
    result = subprocess.run(
        ["chezmoi", "source-path"],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=15,
        check=True,
    )
    return Path(result.stdout.strip()).resolve()


def require_scope(path):
    candidate = Path(path).resolve()
    repo = repository(candidate)
    code = (Path.home() / "Code").resolve()
    if candidate != repo or (repo != source_dir() and repo.parent != code):
        raise ValueError(
            "repository must be the chezmoi source or a top-level ~/Code worktree"
        )
    return repo


def current(repo):
    result = git(repo, "symbolic-ref", "--quiet", "HEAD", check=False)
    if result.returncode not in (0, 1):
        raise ValueError("cannot determine current branch")
    branch = result.stdout.strip() or None
    result = git(repo, "rev-parse", "--verify", "HEAD^{commit}", check=False)
    if result.returncode:
        ref = (
            git(repo, "show-ref", "--verify", "--quiet", branch, check=False)
            if branch
            else None
        )
        if ref is None or ref.returncode != 1:
            raise ValueError("cannot determine HEAD")
        return None, branch
    return result.stdout.strip(), branch


def state_path(repo, directory):
    identity = os.path.normcase(os.path.realpath(repo))
    return directory / f"{hashlib.sha256(os.fsencode(identity)).hexdigest()}.json"


def read_record(path, repo):
    try:
        with path.open(encoding="utf-8") as handle:
            record = json.load(handle)
    except FileNotFoundError:
        return {"version": 2, "repo": str(repo), "branches": {}}
    if not isinstance(record, dict) or record.get("repo") != str(repo):
        raise ValueError(f"invalid sync record: {path}")
    if set(record) == {"repo", "branch", "base"}:
        record = {
            "version": 2,
            "repo": str(repo),
            "branches": {
                record["branch"]: {
                    "checkpoint": None,
                    "verified": False,
                    "pending": record["base"],
                    "actions": {},
                }
            },
        }
    if record.get("version") != 2 or not isinstance(record.get("branches"), dict):
        raise ValueError(f"invalid sync record: {path}")
    for branch, entry in record["branches"].items():
        if (
            not isinstance(branch, str)
            or not isinstance(entry, dict)
            or set(entry) != {"checkpoint", "verified", "pending", "actions"}
        ):
            raise ValueError(f"invalid sync record: {path}")
        if not isinstance(entry["verified"], bool) or not isinstance(
            entry["actions"], dict
        ):
            raise TypeError(f"invalid sync record: {path}")
        if any(
            value is not None and not isinstance(value, str)
            for value in (entry["checkpoint"], entry["pending"])
        ):
            raise ValueError(f"invalid sync record: {path}")
        if any(
            not isinstance(value, dict)
            or set(value)
            not in ({"head", "status"}, {"head", "status", "reviewed_head"})
            or not isinstance(value["head"], str)
            or value["status"] not in ("started", "done")
            or (
                "reviewed_head" in value
                and (
                    value["status"] != "done"
                    or not isinstance(value["reviewed_head"], str)
                )
            )
            for value in entry["actions"].values()
        ):
            raise ValueError(f"invalid sync record: {path}")
    return record


def write_record(path, record):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            json.dump(record, handle, ensure_ascii=True)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temp, path)
        if os.name != "nt":
            directory = os.open(path.parent, os.O_RDONLY)
            try:
                try:
                    os.fsync(directory)
                except OSError as error:
                    if error.errno not in (errno.EINVAL, errno.ENOTSUP):
                        raise
            finally:
                os.close(directory)
    finally:
        if os.path.exists(temp):
            os.unlink(temp)


def is_ancestor(repo, base, head):
    result = git(repo, "merge-base", "--is-ancestor", base, head, check=False)
    if result.returncode not in (0, 1):
        raise ValueError("cannot check commit ancestry")
    return result.returncode == 0


def entry_for(record, branch):
    return record["branches"].setdefault(
        branch, {"checkpoint": None, "verified": False, "pending": None, "actions": {}}
    )


def set_baseline(record, repo, head, branch, base=None):
    entry = entry_for(record, branch)
    chosen = checked_base(repo, base or head, head)
    if entry["pending"]:
        raise ValueError("pending work already has a baseline")
    if entry["checkpoint"] and (
        entry["verified"]
        or not base
        or not is_ancestor(repo, chosen, entry["checkpoint"])
    ):
        raise ValueError("cannot replace the existing baseline")
    entry.update(checkpoint=chosen, verified=False)


def checked_head(repo, expected, expected_branch=None):
    head, branch = current(repo)
    if branch is None:
        raise ValueError("HEAD is detached")
    if head is None:
        raise ValueError("branch has no commits")
    if head != expected:
        raise ValueError("HEAD changed since inspection; recheck the repository")
    if expected_branch is not None and branch != expected_branch:
        raise ValueError("branch changed since inspection; recheck the repository")
    return head, branch


def checked_base(repo, base, head):
    resolved = git(repo, "rev-parse", "--verify", f"{base}^{{commit}}", check=False)
    if (
        resolved.returncode
        or resolved.stdout.strip() != base
        or not is_ancestor(repo, base, head)
    ):
        raise ValueError(
            "baseline must be a full commit ID that is an ancestor of HEAD"
        )
    return base


def status(repo, directory):
    head, branch = current(repo)
    record = read_record(state_path(repo, directory), repo)
    entry = record["branches"].get(branch, {})
    checkpoint, pending = entry.get("checkpoint"), entry.get("pending")
    base = pending or checkpoint
    return {
        "repo": str(repo),
        "head": head,
        "current_branch": branch,
        "checkpoint": checkpoint,
        "verified": entry.get("verified", False),
        "pending": bool(pending),
        "needs_review": bool(pending or (checkpoint and checkpoint != head)),
        "base": base,
        "base_is_ancestor": is_ancestor(repo, base, head) if base and head else None,
        "actions": entry.get("actions", {}),
        "other_pending_branches": [
            key
            for key, value in record["branches"].items()
            if key != branch and value["pending"]
        ],
    }


def begin(record, repo, head, branch, base=None):
    if any(
        key != branch and entry["pending"] for key, entry in record["branches"].items()
    ):
        raise ValueError("another branch has unfinished work")
    entry = entry_for(record, branch)
    if base and (entry["pending"] or entry["checkpoint"]):
        raise ValueError("cannot replace an existing baseline")
    original = entry["pending"] or entry["checkpoint"] or base or head
    checked_base(repo, original, head)
    entry["pending"] = original
    return entry


def operation_in_progress(repo):
    names = (
        "MERGE_HEAD",
        "CHERRY_PICK_HEAD",
        "REVERT_HEAD",
        "rebase-merge",
        "rebase-apply",
        "sequencer",
        "BISECT_LOG",
        "index.lock",
    )
    arguments = [argument for name in names for argument in ("--git-path", name)]
    paths = git(
        repo, "rev-parse", "--path-format=absolute", *arguments
    ).stdout.splitlines()
    if len(paths) != len(names):
        raise ValueError("cannot inspect Git operation state")
    for name, path in zip(names, paths):
        if Path(path).exists():
            return name
    return None


def hook_paths(repo, names):
    arguments = [
        argument for name in names for argument in ("--git-path", f"hooks/{name}")
    ]
    paths = git(
        repo, "rev-parse", "--path-format=absolute", *arguments
    ).stdout.splitlines()
    if len(paths) != len(names):
        raise ValueError("cannot inspect Git hooks")
    return {name: Path(path) for name, path in zip(names, paths)}


def check_hooks(repo, names, head=None, target=None):
    paths = hook_paths(repo, names)
    for name, path in paths.items():
        if path.exists() or path.is_symlink():
            raise ValueError(f"active {name} hook requires manual review")

    if not head or not target:
        return
    changes = git(
        repo,
        "diff",
        "--no-ext-diff",
        "--no-textconv",
        "--no-renames",
        "--name-only",
        "-z",
        head,
        target,
        binary=True,
    ).stdout.split(b"\0")

    def normalized(path):
        return unicodedata.normalize(
            "NFC", path.decode("utf-8", "surrogateescape")
        ).casefold()

    changes = {normalized(path) for path in changes if path}
    for name, path in paths.items():
        for directory in {path.parent, path.resolve().parent}:
            try:
                relative = directory.relative_to(repo)
            except ValueError:
                continue
            if not relative.parts:
                candidates = {normalized(os.fsencode(name))}
                prefix = None
            else:
                candidates = {
                    normalized(os.fsencode(Path(*relative.parts[:index]).as_posix()))
                    for index in range(1, len(relative.parts) + 1)
                }
                prefix = normalized(os.fsencode(relative.as_posix() + "/"))
            if changes.intersection(candidates) or (
                prefix and any(change.startswith(prefix) for change in changes)
            ):
                raise ValueError(f"incoming {name} hook requires manual review")


def check_filters(repo, head=None, target=None):
    configured = git(
        repo,
        "config",
        "-z",
        "--name-only",
        "--get-regexp",
        r"^filter\..*\.(clean|smudge|process)$",
        check=False,
        binary=True,
    )
    if configured.returncode == 1:
        return
    if configured.returncode:
        raise ValueError("cannot inspect configured Git filters")
    drivers = {
        name.removeprefix(b"filter.").rsplit(b".", 1)[0]
        for name in configured.stdout.split(b"\0")
        if name
    }
    paths = git(repo, "ls-files", "-z", binary=True).stdout
    if head and target:
        paths += git(
            repo,
            "diff",
            "--no-ext-diff",
            "--no-textconv",
            "--no-renames",
            "--name-only",
            "-z",
            head,
            target,
            binary=True,
        ).stdout
    if not paths:
        return
    sources = ((), ("--cached",))
    if head and target:
        sources += ((f"--source={head}",), (f"--source={target}",))
    for source in sources:
        result = git(
            repo,
            "check-attr",
            *source,
            "-z",
            "--stdin",
            "filter",
            input=paths,
            binary=True,
        )
        values = result.stdout.split(b"\0")
        if not values or values[-1] or (len(values) - 1) % 3:
            raise ValueError("cannot inspect Git filter attributes")
        if any(value in drivers for value in values[2::3]):
            raise ValueError("configured Git filters require manual review")


def ignored_work(repo):
    return bool(
        git(
            repo,
            "ls-files",
            "--others",
            "--ignored",
            "--exclude-standard",
            "--directory",
            "-z",
            binary=True,
        ).stdout
    )


def has_submodules(repo):
    entries = git(repo, "ls-files", "--stage", "-z", binary=True).stdout.split(b"\0")
    return any(entry.startswith(b"160000 ") for entry in entries)


def upstream(repo, branch):
    if not branch or not branch.startswith("refs/heads/"):
        raise ValueError("no checked-out branch")
    name = branch.removeprefix("refs/heads/")
    remote = git(
        repo, "config", "--get", f"branch.{name}.remote", check=False
    ).stdout.strip()
    merge = git(
        repo, "config", "--get-all", f"branch.{name}.merge", check=False
    ).stdout.splitlines()
    if not re.fullmatch(r"[A-Za-z0-9_][A-Za-z0-9_.-]*", remote) or len(merge) != 1:
        raise ValueError("no configured remote upstream")
    ref = merge[0]
    if (
        not ref.startswith("refs/heads/")
        or git(repo, "check-ref-format", ref, check=False).returncode
    ):
        raise ValueError("unsupported upstream ref")
    urls = git(repo, "remote", "get-url", "--all", remote, check=False)
    addresses = urls.stdout.splitlines()
    if (
        urls.returncode
        or len(addresses) != 1
        or not addresses[0]
        or "::" in addresses[0]
    ):
        raise ValueError("unsupported or missing remote URL")
    return remote, ref


def upstream_head(repo):
    result = git(repo, "rev-parse", "--verify", "@{upstream}^{commit}", check=False)
    if result.returncode:
        raise ValueError("upstream tracking ref unavailable")
    return result.stdout.strip()


def upstream_ref(repo):
    result = git(repo, "rev-parse", "--symbolic-full-name", "@{upstream}", check=False)
    ref = result.stdout.strip()
    if (
        result.returncode
        or not ref.startswith("refs/remotes/")
        or git(repo, "check-ref-format", ref, check=False).returncode
    ):
        raise ValueError("upstream must map to a remote-tracking ref")
    symbolic = git(repo, "symbolic-ref", "--quiet", ref, check=False)
    if symbolic.returncode != 1:
        raise ValueError("symbolic upstream tracking ref requires manual review")
    return ref


def fetch(repo, directory, allow_hooks=False):
    path = state_path(repo, directory)
    with locked(path.with_suffix(".lock")):
        head, branch = current(repo)
        if not head or not branch:
            raise ValueError("detached or unborn branch")
        if operation_in_progress(repo):
            raise ValueError("a Git operation is already in progress")
        remote, ref = upstream(repo, branch)
        tracking = upstream_ref(repo)
        if not allow_hooks:
            check_hooks(repo, ("reference-transaction",))
        result = git(
            repo,
            "fetch",
            "--no-prune",
            "--no-prune-tags",
            "--no-tags",
            "--no-recurse-submodules",
            "--no-auto-maintenance",
            "--refmap=",
            "--",
            remote,
            f"+{ref}:{tracking}",
            check=False,
            timeout=45,
        )
        if result.returncode:
            raise ValueError(
                f"fetch failed (exit {result.returncode}); check authentication and network"
            )
        return upstream_head(repo)


def observe(repo, directory, expected_head, expected_branch):
    path = state_path(repo, directory)
    with locked(path.with_suffix(".lock")):
        head, branch = current(repo)
        if head != expected_head or branch != expected_branch:
            raise ValueError("branch or HEAD changed while recording baseline")
        record = read_record(path, repo)
        entry = entry_for(record, branch)
        if not entry["checkpoint"] and not entry["pending"]:
            entry["checkpoint"] = head
            entry["verified"] = False
            write_record(path, record)


def inspect(repo, directory, do_fetch=False, initialize=False, allow_filters=False):
    result = {"repo": str(repo)}
    try:
        result.update(status(repo, directory))
        head, branch = result["head"], result["current_branch"]
        if not head or not branch:
            result["issue"] = "detached or unborn branch"
            return result
        if initialize and not result["checkpoint"] and not result["pending"]:
            observe(repo, directory, head, branch)
            result.update(status(repo, directory))
        result["submodule_status_unknown"] = has_submodules(repo) and not allow_filters
        if not allow_filters:
            try:
                check_filters(repo)
            except ValueError as error:
                result["filter_issue"] = str(error)
        if result.get("filter_issue"):
            result["dirty"] = None
        else:
            result["dirty"] = bool(
                git(
                    repo,
                    "status",
                    "--porcelain",
                    "--untracked-files=normal",
                    "--ignore-submodules=none"
                    if allow_filters
                    else "--ignore-submodules=all",
                ).stdout
            )
        result["ignored"] = ignored_work(repo)
        result["operation"] = operation_in_progress(repo)
        remote, ref = upstream(repo, branch)
        result["upstream"] = f"{remote}/{ref.removeprefix('refs/heads/')}"
        if result["operation"]:
            result["issue"] = "a Git operation is already in progress"
            return result
        target = fetch(repo, directory) if do_fetch else upstream_head(repo)
        counts = git(
            repo, "rev-list", "--left-right", "--count", f"{head}...{target}"
        ).stdout.split()
        result.update(target=target, ahead=int(counts[0]), behind=int(counts[1]))
        if result["behind"]:
            paths = git(
                repo,
                "diff",
                "--no-ext-diff",
                "--no-textconv",
                "--no-renames",
                "--name-only",
                head,
                target,
            ).stdout.splitlines()
            result["changed_paths"] = paths[:100]
            result["changed_paths_truncated"] = len(paths) > 100
    except (ValueError, TypeError, OSError, subprocess.SubprocessError) as error:
        result["issue"] = str(error)
    return result


def scan(directory, do_fetch, initialize=False):
    paths = [source_dir()]
    code = Path.home() / "Code"
    if code.is_dir():
        paths.extend(
            sorted(
                (p for p in code.iterdir() if p.is_dir()),
                key=lambda p: p.name.casefold(),
            )
        )
    repos, seen, skipped = [], set(), []
    for candidate in paths:
        try:
            repo = repository(candidate)
            if repo != candidate.resolve() or (
                repo != paths[0] and repo.parent != code.resolve()
            ):
                skipped.append(str(candidate))
            elif repo not in seen:
                seen.add(repo)
                repos.append(repo)
        except (ValueError, OSError, subprocess.SubprocessError):
            skipped.append(str(candidate))
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        results = list(
            pool.map(lambda repo: inspect(repo, directory, do_fetch, initialize), repos)
        )
    return {"remote_checked": do_fetch, "repositories": results, "skipped": skipped}


def advance(
    repo,
    directory,
    expected_head,
    expected_branch,
    target,
    allow_hooks=False,
    allow_filters=False,
):
    path = state_path(repo, directory)
    with locked(path.with_suffix(".lock")):
        head, branch = checked_head(repo, expected_head, expected_branch)
        if operation_in_progress(repo):
            raise ValueError("a Git operation is already in progress")
        upstream(repo, branch)
        if upstream_head(repo) != target:
            raise ValueError("upstream changed since inspection")
        if target == head or is_ancestor(repo, target, head):
            return {
                "updated": False,
                "head": head,
                "reason": "up to date or locally ahead",
            }
        if not is_ancestor(repo, head, target):
            raise ValueError("branch and upstream diverged")
        if not allow_filters:
            check_filters(repo, head, target)
        if not allow_hooks:
            check_hooks(
                repo,
                ("reference-transaction", "post-index-change", "post-merge"),
                head,
                target,
            )
        record = read_record(path, repo)
        if entry_for(record, branch)["actions"]:
            raise ValueError("finish or resolve recorded actions before another update")
        begin(record, repo, head, branch)
        write_record(path, record)
        checked_head(repo, expected_head, expected_branch)
        result = git(
            repo,
            "merge",
            "--ff-only",
            "--no-autostash",
            "--no-overwrite-ignore",
            target,
            check=False,
            timeout=45,
        )
        if result.returncode:
            raise ValueError(
                "fast-forward refused; inspect local and ignored files before resolving"
            )
        new_head, new_branch = current(repo)
        if new_head != target or new_branch != branch:
            raise ValueError(
                "branch or HEAD changed during update; follow-up remains pending"
            )
        return {"updated": True, "previous_head": head, "head": new_head}


def recover_bootstrap(directory, bootstrap_from):
    marker = directory / "bootstrap-pending"
    try:
        lines = marker.read_text(encoding="utf-8").splitlines()
    except FileNotFoundError:
        lines = None
    if lines is not None:
        if len(lines) != 3 or not re.fullmatch(r"[0-9a-f]{40}|[0-9a-f]{64}", lines[0]):
            raise ValueError(f"invalid bootstrap marker: {marker}")
        saved_head, saved_branch, saved_source = lines
        if bootstrap_from and bootstrap_from != saved_head:
            raise ValueError("bootstrap marker conflicts with --bootstrap-from")
        bootstrap_from = saved_head
    if not bootstrap_from:
        return
    repo = source_dir()
    if lines is not None and os.path.normcase(
        os.path.realpath(saved_source)
    ) != os.path.normcase(os.path.realpath(repo)):
        raise ValueError("bootstrap marker belongs to a different chezmoi source")
    path = state_path(repo, directory)
    with locked(path.with_suffix(".lock")):
        head, branch = current(repo)
        if not head or not branch:
            raise ValueError("chezmoi source has a detached or unborn branch")
        if lines is not None and branch != saved_branch:
            raise ValueError("bootstrap branch changed; return to the recorded branch")
        record = read_record(path, repo)
        set_baseline(record, repo, head, branch, bootstrap_from)
        write_record(path, record)
    if lines is not None:
        marker.unlink()


def launch(directory, preview, bootstrap_from=None):
    if preview and bootstrap_from:
        raise ValueError("--bootstrap-from cannot be used with --preview")
    with locked(directory / "session.lock", blocking=False) as handle:
        handle.seek(1)
        handle.truncate(1)
        handle.write(b"preview" if preview else b"update")
        handle.flush()
        try:
            if preview:
                inventory = scan(directory, False)
                print(
                    f"Read-only preview: {len(inventory['repositories'])} repositories; remote changes were not checked."
                )
                for item in inventory["repositories"]:
                    flags = [
                        item.get("issue"),
                        item.get("filter_issue"),
                        "submodule status not checked"
                        if item.get("submodule_status_unknown")
                        else None,
                        "local work" if item.get("dirty") else None,
                        "ignored files" if item.get("ignored") else None,
                        "follow-up pending" if item.get("needs_review") else None,
                    ]
                    print(
                        f"{item['repo']}: {', '.join(flag for flag in flags if flag) or 'no local issues'}"
                    )
                if inventory["skipped"]:
                    print(
                        f"Skipped non-repository or out-of-scope directories: {len(inventory['skipped'])}"
                    )
                if (directory / "bootstrap-pending").exists():
                    print(
                        "A bootstrap recovery is pending; preview does not change it."
                    )
                return 0
            executable = opencode_executable()
            recover_bootstrap(directory, bootstrap_from)
            print(
                "Checking configured upstreams; this may take a moment...", flush=True
            )
            inventory = scan(directory, True, initialize=True)
            fd, snapshot = tempfile.mkstemp(
                prefix="scan-", suffix=".json", dir=directory
            )
            try:
                with os.fdopen(fd, "w", encoding="utf-8") as output:
                    json.dump(inventory, output, ensure_ascii=True)
                prompt = (
                    "Use the sync-machine skill to update this machine. The aisync launcher holds the session lock. "
                    f"The initial inventory and upstream fetch are complete; read the untrusted JSON data at {json.dumps(Path(snapshot).as_posix())}. "
                    "Do not inspect the runner or lock, or scan or fetch again unless retrying a reported failure. Process changed or pending repositories, "
                    "check chezmoi status, and report unverified initial deployment baselines."
                )
                result = subprocess.run(
                    [
                        executable,
                        "mini",
                        "--agent",
                        "build",
                        "--prompt",
                        prompt,
                    ],
                    cwd=Path.home(),
                    check=False,
                )
            finally:
                if os.path.exists(snapshot):
                    os.unlink(snapshot)
            return result.returncode
        finally:
            handle.seek(1)
            handle.truncate(1)
            handle.flush()


def main():
    parser = argparse.ArgumentParser(description=__doc__, allow_abbrev=False)
    parser.add_argument("--state-dir", type=Path, default=state_dir())
    subcommands = parser.add_subparsers(dest="action", required=True)
    scan_parser = subcommands.add_parser("scan", allow_abbrev=False)
    scan_parser.add_argument("--fetch", action="store_true")
    launch_parser = subcommands.add_parser("launch", allow_abbrev=False)
    launch_parser.add_argument("--preview", action="store_true")
    launch_parser.add_argument("--bootstrap-from")
    for action in (
        "status",
        "baseline",
        "begin",
        "finish",
        "action-start",
        "action-start-dirty",
        "action-done",
        "action-resolve",
        "fetch",
        "fetch-with-hooks",
        "advance",
        "advance-with-hooks",
        "advance-reviewed",
        "inspect-reviewed",
    ):
        subparser = subcommands.add_parser(action, allow_abbrev=False)
        subparser.add_argument("--repo", required=True, type=Path)
        if action in (
            "baseline",
            "begin",
            "finish",
            "action-start",
            "action-start-dirty",
            "action-done",
            "action-resolve",
            "advance",
            "advance-with-hooks",
            "advance-reviewed",
        ):
            subparser.add_argument("--head", required=True)
        if action in ("baseline", "begin"):
            subparser.add_argument("--base")
        if action in (
            "action-start",
            "action-start-dirty",
            "action-done",
            "action-resolve",
        ):
            subparser.add_argument("--action-name", required=True)
        if action == "action-resolve":
            subparser.add_argument("--action-head", required=True)
            subparser.add_argument(
                "--result", choices=("done", "not-applied", "sufficient"), required=True
            )
        if action in ("advance", "advance-with-hooks", "advance-reviewed"):
            subparser.add_argument("--branch", required=True)
            subparser.add_argument("--target", required=True)
    args = parser.parse_args()

    if args.action == "launch":
        return launch(args.state_dir, args.preview, args.bootstrap_from)
    if (
        args.action not in ("scan", "status") or (args.action == "scan" and args.fetch)
    ) and session_kind(args.state_dir) != b"update":
        raise ValueError("updates require an active aisync launcher session")
    if args.action == "scan":
        print(json.dumps(scan(args.state_dir, args.fetch)))
        return 0
    repo = require_scope(args.repo)
    if args.action in ("fetch", "fetch-with-hooks"):
        print(
            json.dumps(
                {
                    "repo": str(repo),
                    "target": fetch(
                        repo, args.state_dir, args.action == "fetch-with-hooks"
                    ),
                }
            )
        )
        return 0
    if args.action in ("advance", "advance-with-hooks", "advance-reviewed"):
        print(
            json.dumps(
                advance(
                    repo,
                    args.state_dir,
                    args.head,
                    args.branch,
                    args.target,
                    args.action in ("advance-with-hooks", "advance-reviewed"),
                    args.action == "advance-reviewed",
                )
            )
        )
        return 0
    if args.action == "status":
        print(json.dumps(status(repo, args.state_dir)))
        return 0
    if args.action == "inspect-reviewed":
        print(json.dumps(inspect(repo, args.state_dir, allow_filters=True)))
        return 0

    path = state_path(repo, args.state_dir)
    with locked(path.with_suffix(".lock")):
        head, branch = checked_head(repo, args.head)
        record = read_record(path, repo)
        entry = entry_for(record, branch)
        if args.action == "baseline":
            set_baseline(record, repo, head, branch, args.base)
        elif args.action == "begin":
            begin(record, repo, head, branch, args.base)
        elif args.action in (
            "action-start",
            "action-start-dirty",
            "action-done",
            "action-resolve",
        ):
            if (
                not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", args.action_name)
                or len(args.action_name) > 64
            ):
                raise ValueError("invalid action name")
            if not entry["pending"]:
                raise ValueError("begin follow-up before recording an action")
            if args.action in ("action-start", "action-start-dirty"):
                if (
                    entry["actions"].get(args.action_name, {}).get("status")
                    == "started"
                ):
                    raise ValueError(
                        "action was interrupted or is still running; inspect before retrying"
                    )
                if args.action == "action-start":
                    check_filters(repo)
                    if (
                        has_submodules(repo)
                        or ignored_work(repo)
                        or git(
                            repo,
                            "status",
                            "--porcelain",
                            "--untracked-files=normal",
                            "--ignore-submodules=all",
                        ).stdout
                    ):
                        raise ValueError(
                            "repository contains local or ignored files or submodules; obtain approval before deploying it"
                        )
                entry["actions"][args.action_name] = {"head": head, "status": "started"}
            elif args.action == "action-done":
                action = entry["actions"].get(args.action_name)
                if not action or action != {"head": head, "status": "started"}:
                    raise ValueError("no matching action in progress for this HEAD")
                action["status"] = "done"
            else:
                action = entry["actions"].get(args.action_name)
                if not action or action["head"] != args.action_head:
                    raise ValueError("no matching recorded action")
                if args.result == "done":
                    action["status"] = "done"
                elif args.result == "not-applied":
                    del entry["actions"][args.action_name]
                else:
                    if action["status"] != "done":
                        raise ValueError(
                            "resolve the action outcome before reviewing its sufficiency"
                        )
                    checked_base(repo, action["head"], head)
                    action["reviewed_head"] = head
        else:
            if not entry["pending"]:
                raise ValueError("no pending follow-up to finish")
            checked_base(repo, entry["pending"], head)
            if any(
                value["status"] != "done"
                or (value["head"] != head and value.get("reviewed_head") != head)
                for value in entry["actions"].values()
            ):
                raise ValueError(
                    "an action is unfinished or was run for a different HEAD"
                )
            entry.update(checkpoint=head, verified=True, pending=None, actions={})
        write_record(path, record)
    print(json.dumps(status(repo, args.state_dir)))
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, TypeError, subprocess.SubprocessError) as error:
        print(f"sync-machine: {error}", file=sys.stderr)
        sys.exit(1)
