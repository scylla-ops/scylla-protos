# scylla-protos: agent guide

## What this repository is

This repository contains the Protocol Buffers contract of Scylla and the Rust
crate `scylla-proto` that compiles it. It contains the `.proto` files,
`buf.yaml`, a `justfile`, and the crate (`Cargo.toml`, `build.rs`,
`src/lib.rs`).

## Layout rules

- The repository root is the include root. `buf.yaml` sets the module path to
  `.`, and `build.rs` uses the crate root as the only include root.
- The path of a file is its package. `scylla/job/v1/job.proto` declares
  `package scylla.job.v1`.
- Imports use paths from the root, for example
  `import "scylla/common/v1/common.proto";`.
- Do not move a file to a different directory. The backend and the web UI
  use these paths.
- A breaking change goes into a new `v2` directory. Do not change `v1` in a
  breaking way.
- `build.rs` lists each `.proto` file by name. When you add a file, add it to
  that list and add its module to `src/lib.rs`.
- The crate holds generated code only. It must not depend on a Scylla crate.
  The conversions to the domain types are in the backend.

## Consumers

- The backend (`scylla-ops/scylla`) gets the crate as a cargo git dependency
  with a `rev`. Use the HTTPS URL
  `https://github.com/scylla-ops/scylla-protos.git`: this repository is public,
  and CI, Docker and cargo git dependencies must get it without a key.
- The web UI (`scylla-ops/scylla-web`) has this repository as a git submodule
  at `protos/`.

## Commands

| Command | Use |
|---|---|
| `just lint` | Lint all files. |
| `just fmt` | Format all files. This command changes the files. |
| `just breaking` | Compare the files with the `main` branch of this repository. |
| `just breaking '<input>'` | Compare the files with a different buf input. |
| `just build` | Build the crate and run clippy. |

Do these checks before each commit.

## History

The history before this repository comes from the backend repository. The
files were at `libs/protocol/proto`, then at `crates/scylla-protocol/proto`,
then at `crates/scylla-proto/proto`. The import made each of these directories
the root.

## Commits

Use the format `<type>: <description>`. Do not add a body or a footer.
