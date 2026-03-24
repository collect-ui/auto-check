# AGENTS.md

Guidance for coding agents working in `/data/project/auto-check`.

## Project Snapshot

- Module: `moon`
- Language: Go `1.23` in `go.mod`
- HTTP framework: Gin
- Core architecture: low-code backend driven by YAML/JSON configuration plus Go plugins
- Main entrypoint: `main.go`
- Key areas: `model/`, `plugins/`, `collect/`, `conf/`, `frontend/`
- Local dependency override: `go.mod` contains `replace github.com/collect-ui/collect => ../collect`

## Instruction Files

- No `.cursor/rules/` directory was found.
- No `.cursorrules` file was found.
- No `.github/copilot-instructions.md` file was found.
- The repository-specific agent guidance currently lives in this file only.

## Common Commands

### Run Locally

```bash
go run main.go
```

Use this for local development when you want to boot the Gin server with the current config.

### Build

Linux/macOS build script:

```bash
./build.sh
```

What `build.sh` does:

- clears `dist/`
- runs `go build -o dist/bin -v -x`
- compresses with `upx`
- copies `static/`, `conf/`, `collect/`, `frontend/`, scripts, and `database/` into `dist/`

Direct Go build:

```bash
go build ./...
go build -o moon.exe main.go
```

Windows helper script:

```bat
build-windows.bat
```

Equivalent Windows build command:

```bash
go build -ldflags="-s -w" -o windows/main.exe -v main.go
```

Note: the Windows script also runs a hard-coded UPX path: `F:\upx-5.1.0-win64\upx.exe`.

### Tests

There are currently no `*_test.go` files in this repository, so `go test` mostly validates package compilation.

Run all tests/packages:

```bash
go test ./...
```

Verbose:

```bash
go test -v ./...
```

Run one package:

```bash
go test ./plugins/...
go test ./model/...
```

Run a single test when tests exist:

```bash
go test -v -run TestName ./path/to/package
```

Run a single subtest when tests exist:

```bash
go test -v -run 'TestName/Subcase' ./path/to/package
```

Coverage:

```bash
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### Formatting and Linting

Format all packages:

```bash
go fmt ./...
```

Vet all packages:

```bash
go vet ./...
```

Module cleanup:

```bash
go mod tidy
```

Optional tools if available locally:

```bash
staticcheck ./...
golangci-lint run
```

## Recommended Validation Flow

For a typical Go code change:

1. `go fmt ./...`
2. `go test ./...`
3. `go vet ./...`

For config-only changes in `collect/` or `conf/`, at minimum run:

1. `go test ./...`
2. start the app with `go run main.go` if behavior depends on runtime wiring

## Repository Structure

- `main.go`: application bootstrap and HTTP server wiring
- `model/`: domain models and table registration
- `plugins/`: custom low-code/plugin handlers
- `collect/`: YAML/JSON service definitions and UI/page metadata
- `conf/`: application properties
- `frontend/`: static frontend assets
- `database/`: local databases; treat as environment data, not source

## Code Style Guidelines

### Imports

- Group imports in Go standard order: standard library, third-party, local project imports.
- Keep one import block per file unless Go requires otherwise.
- Use aliases only when they add clarity or avoid collisions.
- Preserve existing aliases like `templateService`, `utils`, or `config` when editing nearby code.

### Formatting

- Use `gofmt` formatting; do not hand-format Go code.
- Keep files ASCII unless the file already contains Chinese text or business labels that require it.
- Prefer small, focused changes that match surrounding style rather than broad rewrites.

### Naming

- Package names are lowercase and usually a single word.
- Exported identifiers use PascalCase.
- Unexported identifiers use camelCase.
- Multi-word filenames use snake_case where that pattern already exists, especially in `plugins/handler_params_*.go`.
- Keep domain terminology consistent with existing names like `GetTable`, `Result`, `GetRegisterList`, and `TemplateService`.

### Types and Structs

- Embed shared base structs when the pattern already exists, e.g. `BaseHandler`, `BaseFlow`.
- Keep struct field order stable unless there is a clear reason to reorder.
- Follow existing registration patterns:
  - models register in `model/register.go`
  - plugins register in `plugins/a_register.go`

### Error Handling

- Check errors immediately.
- Return contextual errors with `fmt.Errorf` when bubbling up internal failures.
- In handler/plugin code, match existing result patterns such as `common.NotOk(...)` instead of introducing a new style.
- Avoid panics in request-path code unless the surrounding code already treats them as fatal startup errors.

### Control Flow

- Prefer early returns for validation failures.
- Keep plugin `Result` methods linear and easy to scan.
- Reuse existing helper functions before adding new abstractions.

### Comments

- Match the repository pattern: Chinese comments are common for business logic; English is acceptable for technical explanations.
- Document exported functions/types when adding new public API surface.
- Keep comments short and focused on intent, not line-by-line narration.

### Configuration and Low-Code Files

- Many features are implemented in YAML/JSON under `collect/` rather than Go.
- Preserve key names, indentation style, and schema shape when editing configuration-driven files.
- Avoid mass reformatting JSON/YAML unless the file is already being normalized for a reason.
- Check for references across `collect/`, `conf/`, and plugin code before renaming service keys.

### Database and Generated Artifacts

- Do not commit local database files, IDE files, binaries, or archives unless the task explicitly requires it.
- Be cautious with `database/`, `windows/`, `bin`, `test/bin`, and similar local artifacts.
- If a change generates files, verify they are intended source artifacts and not environment output.

## Working Conventions for Agents

- Read neighboring files before changing patterns in a subsystem.
- Preserve compatibility with the local `../collect` replace target when changing interfaces.
- When adding a plugin, update both implementation and `plugins/a_register.go`.
- When adding a model, update the relevant domain package and `model/register.go`.
- When behavior is configured, prefer extending config files over hard-coding new branches in Go.

## Practical Notes

- `origin/master` is the only visible remote branch in this checkout.
- The repo contains local runtime assets and historical large files; avoid reintroducing large archives or database blobs.
- Frontend assets exist, but there is no top-level Node build manifest in this repository.
- If a build fails unexpectedly, first verify the sibling `../collect` module exists and is in sync.
