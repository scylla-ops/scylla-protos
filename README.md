# scylla-protos

This repository contains the Protocol Buffers contract of Scylla and the Rust
crate that compiles it, `scylla-proto`.

The Scylla backend and the Scylla web UI use this contract. Each one pins a
commit of this repository.

## Layout

The repository root is the include root. The path of a file below the root is
its package:

```
scylla/<domain>/v1/<file>.proto   ->   package scylla.<domain>.v1;
```

Imports use the same paths, for example
`import "scylla/common/v1/common.proto";`.

Each package has a version suffix. A breaking change goes into a new `v2`
directory next to `v1`. Do not change `v1` in a breaking way.

The root is also a Cargo package. `build.rs` compiles the files with
`tonic-prost-build`, and `src/lib.rs` exposes one module per package. The crate
holds the generated code only. The conversions between these types and the
Scylla domain types stay in the backend.

## Consumers

**Backend** (`scylla-ops/scylla`). The backend gets the crate as a cargo git
dependency, pinned on one commit:

```toml
scylla-proto = { git = "https://github.com/scylla-ops/scylla-protos.git", rev = "<commit>" }
```

This repository is public. Thus CI, Docker builds and cargo git dependencies
(for example the Enterprise repository, which depends on the backend by git
tag) get it without an SSH key or a token.

**Web UI** (`scylla-ops/scylla-web`). The web UI has this repository as a git
submodule at `protos/` and generates its TypeScript clients from it with
`protobuf-ts`. There is no npm package and no Buf Schema Registry module.

## Change the contract

1. Change the `.proto` files here. Add a new file to the list in `build.rs`.
2. Run `just lint`, `just fmt`, `just breaking` and `just build`.
3. Commit and push here.
4. In the backend, change the `rev` of the dependency. In the web UI, move the
   submodule to the new commit.

To try a change in the backend before you push, add a local patch to the
backend's `.cargo/config.toml`, and do not commit it:

```toml
[patch."https://github.com/scylla-ops/scylla-protos.git"]
scylla-proto = { path = "../scylla-protos" }
```

## Checks

Install [buf](https://buf.build/docs/installation),
[just](https://just.systems), `protoc` and the Rust toolchain.

| Command | What it does |
|---|---|
| `just lint` | Runs `buf lint` with the `STANDARD` rules. |
| `just fmt` | Runs `buf format -w`. It changes the files. |
| `just breaking` | Runs `buf breaking` against the `main` branch of this repository. |
| `just breaking '<ref>'` | Runs `buf breaking` against a different buf input, for example `'.git#tag=v0.4.0'`. |
| `just build` | Builds the crate and runs clippy. |

The breaking check uses the `FILE` rules. The rules and the lint exceptions are
in `buf.yaml`, with the reasons.
