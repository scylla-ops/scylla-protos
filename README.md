# scylla-protos

This repository contains the Protocol Buffers contract of Scylla. It contains
the `.proto` files only. It does not contain generated code.

The Scylla backend and the Scylla web UI use this contract. Each one pins a
commit of this repository with a git submodule.

## Layout

The repository root is the include root. The path of a file below the root is
its package:

```
scylla/<domain>/v1/<file>.proto   ->   package scylla.<domain>.v1;
```

Imports use the same paths, for example
`import "scylla/common/v1/id.proto";`.

Each package has a version suffix. A breaking change goes into a new `v2`
directory next to `v1`. Do not change `v1` in a breaking way.

`google/rpc/` holds a subset of googleapis (`status.proto` and
`error_details.proto`, with the same field numbers). The server sends a
`google.rpc.Status` with its details in the trailer
`grpc-status-details-bin`. A client reads it with these files. The backend
does not compile them: it uses `tonic-types`.

## Consumers

**Backend** (`scylla-ops/scylla-ce`). The backend has this repository as a git
submodule at `proto`. The submodule pins one commit. The `scylla-proto` crate
compiles the files of `scylla/` with `tonic-prost-build` and gives the folder
to the dependent crates as `DEP_SCYLLA_PROTO_INCLUDE`.

**Enterprise backend** (`scylla-ops/scylla-ee`). It takes `scylla-proto` from
the backend with a cargo git dependency, and imports the public protos
through `DEP_SCYLLA_PROTO_INCLUDE`.

**Web UI** (`scylla-ops/scylla-web`). The web UI has this repository as a git
submodule at `protos/` and generates its TypeScript clients from it with
`protobuf-ts`. There is no npm package and no Buf Schema Registry module.

The submodule URL is HTTPS:

```
https://github.com/scylla-ops/scylla-protos.git
```

This repository is public. Thus CI and cargo git dependencies can get the
submodule without an SSH key or a token.

To get the files after you clone the backend:

```sh
git clone --recurse-submodules https://github.com/scylla-ops/scylla-ce.git
# or, in an existing clone:
git submodule update --init
```

## Change the contract

1. Change the `.proto` files here.
2. Run `just lint`, `just fmt` and `just breaking`.
3. Commit and push here.
4. In the backend and in the web UI, move the submodule to the new commit and
   commit the new pin with the code that uses it. In the backend, add a new
   file to the list of `scylla-proto/build.rs`.

## Checks

Install [buf](https://buf.build/docs/installation) and
[just](https://just.systems).

| Command | What it does |
|---|---|
| `just lint` | Runs `buf lint` with the `STANDARD` and `COMMENTS` rules. |
| `just fmt` | Runs `buf format -w`. It changes the files. |
| `just breaking` | Runs `buf breaking` against the `main` branch of this repository. |
| `just breaking '<ref>'` | Runs `buf breaking` against a different buf input, for example `'.git#tag=v0.4.0'`. |

The breaking check uses the `FILE` rules. The rules are in `buf.yaml`.
