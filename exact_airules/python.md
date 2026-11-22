# Python

- Update `uv.lock`, `poetry.lock`, or `Pipfile.lock` with `uv`, `poetry`, or `pipenv`.
- If `uv.lock` exists, prefer `uv run`/`uv add`/`uv remove` over bare `python`, `pytest`, or `pip`.
- Run Ruff lint and format checks on changed Python files, including extensionless scripts. Do not bypass diagnostics
  with new suppressions, exclusions, relaxed rules, or `--exit-zero`.
- Do not use `assert` to validate external input or enforce security checks; Python can disable assertions.
- Pass subprocess arguments as a list. Use a shell only when shell semantics are required; never interpolate untrusted
  input into shell code.
- Use `with` or `async with` for resources that support those protocols.
