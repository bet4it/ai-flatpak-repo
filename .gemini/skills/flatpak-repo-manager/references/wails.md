# Packaging Wails Applications

## Build Requirements
- **Go**: 1.21+ (preferably v1.24+).
- **Node.js**: 18+ (preferably v22+).
- **Libraries**: `webkit2gtk-4.1` and `gtk3`. Use **GNOME SDK**.

## Installation Logic
Unpack Go directly into `/app` to ensure the standard library is discoverable at `/app/go/src`.

```yaml
  - name: go
    buildsystem: simple
    build-commands:
      - mkdir -p /app/go
      - cp -r . /app/go/
      - if [ -d "/app/go/go" ]; then mv /app/go/go/* /app/go/ && rm -rf /app/go/go; fi
      - ln -s /app/go/bin/go /app/bin/go
```

## Build Commands
**CRITICAL**: Each line in `build-commands` runs in a separate shell. Use the YAML block scalar `|` to group commands and **ALWAYS start with `set -e`**.

```yaml
    build-commands:
      - |
        set -e
        export GOROOT=/app/go
        export GOPROXY=https://proxy.golang.org,direct
        export GOSUMDB=sum.golang.org
        export GO111MODULE=on
        export GOPATH=/tmp/go
        export PATH=$PATH:/app/bin:$GOROOT/bin:$GOPATH/bin
        
        go mod tidy
        wails build -tags webkit2_41 -platform linux/amd64 -o myapp
```
