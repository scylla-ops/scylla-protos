set quiet

# Show available commands
default:
    @just --list

# Lint every .proto against the buf STANDARD rules
[no-exit-message]
lint:
    buf lint

# Rewrite every .proto in canonical buf formatting
[no-exit-message]
fmt:
    buf format -w

# Fail if the schema breaks wire or source compatibility with a git ref (default: main)
[no-exit-message]
breaking against='.git#branch=main':
    buf breaking --against '{{against}}'
