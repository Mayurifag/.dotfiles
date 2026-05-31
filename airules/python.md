# Lockfiles

Never edit Python lockfiles (`uv.lock`, `poetry.lock`, `Pipfile.lock`) manually. Always use the proper CLI (`uv`, `poetry`, `pipenv`), preferably from makefiles.

# uv

If uv.lock exists, prefer uv run/uv add/uv remove over bare python, pytest, or pip.
