# scylla-protos: agent guide

## What this repository is

This repository contains the Protocol Buffers contract of Scylla. It contains
`.proto` files, `buf.yaml` and a `justfile`. It does not contain generated
code.

## Layout rules

- The repository root is the include root. `buf.yaml` sets the module path to
  `.`.
- The path of a file is its package. `scylla/job/v1/job.proto` declares
  `package scylla.job.v1`.
- Imports use paths from the root, for example
  `import "scylla/common/v1/common.proto";`.
- Do not move a file to a different directory. The backend and the web UI
  use these paths as import paths.
- A breaking change goes into a new `v2` directory. Do not change `v1` in a
  breaking way.

## Consumers

- The backend repository (`scylla-ops/scylla`) has this repository as a git
  submodule at `crates/scylla-proto/proto`. The submodule URL is
  `https://github.com/scylla-ops/scylla-protos.git`. Use HTTPS, not SSH: this
  repository is public, and CI and cargo git dependencies must get it without
  a key.
- `crates/scylla-proto/build.rs` in the backend lists each `.proto` file by
  name. When you add a file here, add it to that list in the backend.
- The web UI (`scylla-ops/scylla-web`) has this repository as a git submodule
  at `protos/`. There is no npm package and no Buf Schema Registry module.

## Commands

| Command | Use |
|---|---|
| `just lint` | Lint all files. |
| `just fmt` | Format all files. This command changes the files. |
| `just breaking` | Compare the files with the `main` branch of this repository. |
| `just breaking '<input>'` | Compare the files with a different buf input. |

Do these checks before each commit.

## History

The history before this repository comes from the backend repository. The
files were at `libs/protocol/proto`, then at `crates/scylla-protocol/proto`,
then at `crates/scylla-proto/proto`. The import made each of these directories
the root.

## Commits

Use the format `<type>: <description>`. Do not add a body or a footer.
