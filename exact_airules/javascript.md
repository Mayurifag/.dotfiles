# JavaScript

- Update lockfiles with the matching `npm install`, `pnpm install`, `yarn install`, or `bun install`.
- When exact integer values may exceed the safe `Number` range, check inputs and intermediate results with
  `Number.isSafeInteger`, or use `BigInt` when the target environment and data format support it.
- Return, await, or explicitly handle promises whose rejection would otherwise be unobserved.
