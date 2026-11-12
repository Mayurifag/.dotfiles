# Rust

## Ownership

- Prefer unique ownership. Use `Rc`/`Arc` for intentional sharing and interior mutability only when needed.
- Do not clone just to silence the borrow checker: shorten borrows, split field access, or move with `mem::take`,
  `mem::replace`, or `Option::take`. Clone deliberately when independent copies are correct.
- Read-only parameters -> `&str`, `&[T]`, `&Path`, or `&T`, not `&String`, `&Vec<T>`, or `&Box<T>`. Consume/store ->
  take ownership; mutate in place -> `&mut T`. Follow framework-required signatures.
- Use ownership and `Drop` guards for resource cleanup. Bind acquired guards to a name; a wildcard binding does not keep
  a newly acquired guard alive.

## Types and APIs

- Model absence with `Option`, failures with `Result`, distinct choices with enums, and units/IDs with newtypes when
  confusion is plausible. Prefer `Path`/`PathBuf` and `Duration` to untyped strings and numbers.
- Validate invariants in constructors; keep fields private when mutation could break them. Public fields are fine for
  passive data. Replace unclear boolean mode arguments with named choices, not every boolean with a new type.
- Add traits, generics, builders, or shared ownership only for actual needs; do not impose library extensibility
  patterns on internal code.
- Implement applicable standard traits rather than lookalike methods: `From`/`TryFrom`, `FromStr`, `Display`, and
  `Default`. Keep `Eq`, `Ord`, `PartialOrd`, and `Hash` consistent, especially with custom comparisons.
- Minimize public API and dependency-type exposure. Derive useful traits deliberately; redact secrets from `Debug`. Use
  `#[non_exhaustive]` only when library evolution needs it.
- `HashMap` iteration order is not stable.

## Errors and Safety

- Propagate recoverable failures with `?`; never panic on invalid external input. Match `Option`/`Result` instead of
  check-then-unwrap. Reserve `expect`/assertions for established invariants and explain why they must hold.
- Public library errors -> typed errors implementing `Error` and `Display`, with wrapped causes preserved. Application
  errors -> the project's context-rich error approach.
- `Drop` must not panic; use an explicit fallible method when cleanup errors must be handled.
- Avoid `unsafe`; prefer standard APIs and reviewed crates. When necessary, isolate it behind a sound safe API and add
  `// SAFETY:` comments explaining the upheld invariants, not just why unsafe is needed. Document unsafe function caller
  obligations under `# Safety`; use Miri when practical. Never use unsafe to bypass lifetime or `Send` requirements.
- Use `checked_*` arithmetic and `TryFrom` conversions as appropriate when bounds or precision affect correctness.

## Async

- Choose sync vs async locks for the runtime and contention pattern; avoid holding guards across `.await` unless needed.
- Keep blocking I/O and long CPU work off async executor threads; use the runtime's blocking pool or a suitable worker.
  Preserve required `Send`/`Sync` contracts without imposing them on intentionally single-threaded code.

## Cargo and Verification

- Update `Cargo.lock` through Cargo. Set the MSRV deliberately; keep dependencies and lint syntax compatible with it.
- For justified lint exceptions, prefer `#[expect(..., reason = "...")]` when the MSRV supports it. Keep
  warnings-as-errors in CI, not `#![deny(warnings)]`.
- Run repository checks; normally `cargo fmt --check`, `cargo clippy --all-targets -- -D warnings`, and `cargo test`.
  Check supported feature combinations; do not assume mutually exclusive features work with `--all-features`.
- Public APIs -> rustdoc with examples and applicable `# Errors`, `# Panics`, and `# Safety` sections. Prefer `?` in
  fallible examples. For libraries, build docs with `cargo doc --no-deps` and run doctests.
- For ports, prefer Rust idioms to copying source-language structure. Port existing tests first.
- Prefer clear loops or short iterator chains over clever code and needless allocations.
