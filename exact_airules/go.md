# Go

- Use the project's Go version and formatter; default to `gofmt` on changed files without reformatting unrelated files.
- Prefer project Make/CI check targets and configured linters such as `golangci-lint`. Otherwise run `go vet` and
  `go test` for affected packages, expanding to `./...` when practical.
- When setting up linting, prefer `golangci-lint` standard checks; add linters only for concrete value and do not
  suppress findings just to pass CI.
- For concurrency changes, run relevant tests with `-race` when supported and practical.
- Use Go tooling for dependency and `go.sum` updates; review `go.mod` and `go.sum` for unrelated churn.
