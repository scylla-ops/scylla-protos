# scylla-protos: agent guide

## What this repository is

This repository contains the Protocol Buffers contract of Scylla. It contains
`.proto` files, `buf.yaml` and a `justfile`. It does not contain generated
code.

## Layout rules

- The repository root is the include root. `buf.yaml` sets the module path to
  `.`.
- The path of a file is its package. `scylla/pipelines/v1/job.proto` declares
  `package scylla.pipelines.v1`.
- Imports use paths from the root, for example
  `import "scylla/common/v1/id.proto";`.
- Do not move a file to a different directory. The backend and the web UI
  use these paths as import paths.
- A breaking change goes into a new `v2` directory. Do not change `v1` in a
  breaking way.
- Each RPC comment gives the permission that the RPC requires and the gRPC
  codes that it returns for a bad request.
- `google/rpc/` is a subset of googleapis for the clients. Do not change its
  field numbers. The lint does not check it.

## Consumers

- The backend repository (`scylla-ops/scylla-ce`) has this repository as a git
  submodule at `proto`. The submodule URL is
  `https://github.com/scylla-ops/scylla-protos.git`. Use HTTPS, not SSH: this
  repository is public, and CI and cargo git dependencies must get it without
  a key.
- `scylla-proto/build.rs` in the backend lists each `.proto` file of
  `scylla/` by name. When you add a file here, add it to that list in the
  backend.
- The Enterprise backend (`scylla-ops/scylla-ee`) gets these files through the
  cargo git dependency on the backend.
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

The history of `scylla/` comes from the folder `ce/proto` of the migration
repository, with `git subtree split`.

## Commits

Use the format `<type>: <description>`. Do not add a body or a footer.
