# Lockfiles

Never edit JavaScript lockfiles (`package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `bun.lock`, `bun.lockb`) manually.
Always use the proper CLI (`npm install`, `pnpm install`, `yarn install`, `bun install`), preferably from package scripts or makefiles.
