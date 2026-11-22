# TypeScript

- Treat external data as `unknown` until validated at the boundary. Use the project's existing guard or schema; a type
  assertion does not validate data.
- Narrow types instead of using `any`, casts, or non-null assertions to bypass a compiler error. Preserve the project's
  type-checking settings; do not relax them to make a change pass.
- Use discriminated unions for mutually exclusive states with different fields. Check all variants when missing one
  would change behavior.
- Run the project's type check in addition to its build when the build only transpiles.
