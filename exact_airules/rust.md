# Rules for rust related projects

## Lockfiles

Never edit `Cargo.lock` manually. Always use the proper CLI (`cargo update`, `cargo generate-lockfile`), preferably from makefiles.

## Unsafe

You are required to avoid `unsafe` code if possible. If not - you are required to add explicit commentary why this codeblock is needed and keep code lines minimal.
