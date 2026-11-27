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
- Each RPC comment gives the permission that the RPC requires and the gRPC
  codes that it returns for a bad request.
- `google/rpc/` is a subset of googleapis for the clients. Do not change its
  field numbers. The lint does not check it.

## Compatibility

Scylla 0.7 runs in production with real users and data. A client of an
older version still calls the server: a web app in an open tab, an agent on
a machine, a script. Thus a change is additive (decision 115 of
`scylla-ce`).

- Never change the type or the meaning of a field number. Never use a
  number again.
- To replace a field, add the new field with the next free number. Mark the
  old field `[deprecated = true]`. Its comment names the new field and the
  version, for example `Deprecated in 0.7.3: read live_status.` The server
  keeps filling the old field.
- Remove the old field only in a later minor version. Add a `reserved` line
  for its number and a `reserved` line for its name.
- An RPC follows the same steps: `option deprecated = true;`, with a comment
  that names the new RPC and the version, then a removal in a later minor
  version.
- Gaps in the field numbers are normal.
- A new meaning of a field is also a breaking change, for example a count
  that now counts fewer items. Add a new field. If no client uses the field
  yet, you can keep the field: then write the new meaning under `Changed` in
  `CHANGELOG.md`.
- `buf breaking` against the base branch must pass (see Commands). Its
  default rules refuse each removal, also with a `reserved` line. For the
  removal of a deprecated field or RPC, use the rules `WIRE_JSON`: they
  accept a removed field when its number and its name are reserved.

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
| `buf breaking --against '.git#ref=origin/<base>'` | Compare the files with the base branch, for example `origin/v0.7.3`. No recipe and no CI run it. |
| `buf breaking --against '.git#ref=origin/<base>' --config '{"version":"v2","breaking":{"use":["WIRE_JSON"]}}'` | The same check, for the removal of a deprecated field or RPC. |

Do these checks before each commit.

## History

The history of `scylla/` comes from the folder `ce/proto` of the migration
repository, with `git subtree split`.

## Commits

Use the format `<type>: <description>`. Do not add a body or a footer.

- Each change that a user or a client can see adds a line to `CHANGELOG.md`, under `[Unreleased]`.
