# Python

- Update `uv.lock`, `poetry.lock`, or `Pipfile.lock` with `uv`, `poetry`, or `pipenv`.
- If `uv.lock` exists, prefer `uv run`/`uv add`/`uv remove` over bare `python`, `pytest`, or `pip`.
- Run Ruff lint and format checks on changed Python files, including extensionless scripts. Do not bypass diagnostics
  with new suppressions, exclusions, relaxed rules, or `--exit-zero`.
