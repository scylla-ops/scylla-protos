set quiet

# Show available commands
default:
    @just --list

# Lint every .proto against the buf STANDARD and COMMENTS rules
[no-exit-message]
lint:
    buf lint

# Rewrite every .proto in canonical buf formatting
[no-exit-message]
fmt:
    buf format -w
