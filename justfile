# =============================================================================
# 📚 Documentation
# =============================================================================
# This justfile provides a comprehensive build system for Go projects of any size.
# It supports development, testing, building, and deployment workflows.
#
# Quick Start:
# 1. Install 'just': https://github.com/casey/just
# 2. Copy this justfile to your project root
# 3. Run `just init` to initialize the project
# 4. Run `just --list` to see available commands
#
# Configuration:
# The justfile can be configured in several ways (in order of precedence):
# 1. Command line: just GOOS=darwin build
# 2. Environment variables: export GOOS=darwin
# 3. .env file in project root
# 4. Default values in this justfile

# =============================================================================
# 🔄 Core Configuration
# =============================================================================

# Enable .env file support for local configuration
set dotenv-load

# Use bash with strict error checking
set shell := ["bash", "-uc"]

# Allow passing arguments to recipes
set positional-arguments

# Common command aliases for convenience
alias t := test
alias b := build
alias r := run
alias d := dev

# =============================================================================
# Variables
# =============================================================================

# Project Settings
# These can be overridden via environment variables or .env file
project_name := env_var_or_default("PROJECT_NAME", "myapp")
organization := env_var_or_default("ORGANIZATION", "myorg")
description := "My Awesome Go Project"
maintainer := "maintainer@example.com"

# Feature flags
# Enable/disable various build features
enable_docker := env_var_or_default("ENABLE_DOCKER", "true")
enable_proto := env_var_or_default("ENABLE_PROTO", "true")
enable_docs := env_var_or_default("ENABLE_DOCS", "true")

# Build configuration
# Tags for conditional compilation
build_tags := ""
extra_tags := ""
all_tags := build_tags + " " + extra_tags

# Test configuration
# Settings for test execution and coverage
test_timeout := "5m"
coverage_threshold := "80"
bench_time := "2s"

# Go settings
# Core Go environment variables and configuration
export GOPATH := env_var_or_default("GOPATH", `go env GOPATH`)
export GOOS := env_var_or_default("GOOS", `go env GOOS`)
export GOARCH := env_var_or_default("GOARCH", `go env GOARCH`)
export CGO_ENABLED := env_var_or_default("CGO_ENABLED", "0")
go := env_var_or_default("GO", "go")
gobin := GOPATH + "/bin"

# Version control
# Automatically detect version information from git
# Falls back to timestamp if not in a git repository
version := if `git rev-parse --git-dir 2>/dev/null; echo $?` == "0" {
    `git describe --tags --always --dirty 2>/dev/null || echo "dev"`
} else {
    `date -u '+%Y%m%d-%H%M%S'`
}
git_commit := `git rev-parse --short HEAD 2>/dev/null || echo "unknown"`
git_branch := `git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown"`
build_time := `date -u '+%Y-%m-%d_%H:%M:%S'`
build_by := `whoami`

# Directories
# Project directory structure
root_dir := justfile_directory()
bin_dir := root_dir + "/bin"
dist_dir := root_dir + "/dist"
docs_dir := root_dir + "/docs"

# Build flags
# Linker flags for embedding version information
ld_flags := "-s -w \
    -X '$(go list -m)/pkg/version.Version=" + version + "' \
    -X '$(go list -m)/pkg/version.Commit=" + git_commit + "' \
    -X '$(go list -m)/pkg/version.Branch=" + git_branch + "' \
    -X '$(go list -m)/pkg/version.BuildTime=" + build_time + "' \
    -X '$(go list -m)/pkg/version.BuildBy=" + build_by + "'"

# Database configuration
export DATABASE_URL := env_var_or_default("DATABASE_URL", "")

# =============================================================================
# Default Recipe
# =============================================================================

# Show available recipes with their descriptions
@default:
    just --list

# =============================================================================
# Project Setup
# =============================================================================

# Initialize a new project with a basic structure and configuration
init:
    #!/usr/bin/env bash
    if [ ! -f "go.mod" ]; then
        {{go}} mod init "$(basename "$(pwd)")"
    fi
    if [ ! -f ".env" ]; then
        echo "# Project Configuration" > .env
        echo "PROJECT_NAME={{project_name}}" >> .env
        echo "ENABLE_DOCKER=true" >> .env
        echo "ENABLE_PROTO=false" >> .env
    fi
    if [ ! -f ".gitignore" ]; then
        curl -sL https://www.gitignore.io/api/go > .gitignore
    fi
    mkdir -p \
        main \
        testdata \
        .github/workflows
    if [ ! -f "main/main.go" ]; then
        mkdir -p main
        printf '%s\n' \
            'package main' \
            '' \
            'import "fmt"' \
            '' \
            'func main() {' \
            '    fmt.Println("Hello, World!")' \
            '}' \
            > main/main.go
    fi
    just deps


# Install all required development tools and dependencies
deps:
    {{go}} mod download
    {{go}} install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    {{go}} install mvdan.cc/gofumpt@latest
    {{go}} install golang.org/x/vuln/cmd/govulncheck@latest
    {{go}} install github.com/golang/mock/mockgen@latest
    {{go}} install github.com/air-verse/air@latest

# Update all project dependencies to their latest versions
deps-update:
    {{go}} get -u ./...
    {{go}} mod tidy

# =============================================================================
# Development
# =============================================================================

# Build the project
build:
    mkdir -p {{bin_dir}}
    {{go}} build \
        -ldflags '{{ld_flags}}' \
        -o {{bin_dir}}/{{project_name}} \
        ./main

# Run the application
run: build
    {{bin_dir}}/{{project_name}}

# Start development with hot reload
dev: deps
    #!/usr/bin/env bash
    if [ ! -f ".air.toml" ]; then
        curl -sL https://raw.githubusercontent.com/air-verse/air/refs/heads/master/air_example.toml > .air.toml
    fi
    {{gobin}}/air -c .air.toml

# Install the application
install: build
    {{go}} install -tags '{{all_tags}}' -ldflags '{{ld_flags}}' ./main

# Generate code
generate:
    {{go}} generate ./...

# =============================================================================
# Testing & Quality
# =============================================================================

# Run tests
test:
    {{go}} test -v -race -cover ./...

# Run tests with coverage
test-coverage:
    {{go}} test -v -race -coverprofile=coverage.out ./...
    {{go}} tool cover -html=coverage.out -o coverage.html

# Run benchmarks
bench:
    {{go}} test -bench=. -benchmem -run=^$ -benchtime={{bench_time}} ./...

# Format code
fmt:
    {{go}} fmt ./...
    {{gobin}}/gofumpt -l -w .

# Run linters
lint:
    {{gobin}}/golangci-lint run --fix

# Run security scan
security:
    {{gobin}}/govulncheck ./...

# Run go vet
vet:
    {{go}} vet ./...

# Cross-compile for all platforms
build-all:
    #!/usr/bin/env sh
    mkdir -p {{dist_dir}}
    for platform in \
        "linux/amd64/-" \
        "linux/arm64/-" \
        "linux/arm/7" \
        "darwin/amd64/-" \
        "darwin/arm64/-" \
        "windows/amd64/-" \
        "windows/arm64/-"; do
        os=$(echo $platform | cut -d/ -f1)
        arch=$(echo $platform | cut -d/ -f2)
        arm=$(echo $platform | cut -d/ -f3)
        output="{{dist_dir}}/{{project_name}}-${os}-${arch}$([ "$os" = "windows" ] && echo ".exe")"
        
        GOOS=$os GOARCH=$arch $([ "$arm" != "-" ] && echo "GOARM=$arm") \
        CGO_ENABLED={{CGO_ENABLED}} {{go}} build \
            -tags '{{all_tags}}' \
            -ldflags '{{ld_flags}}' \
            -o "$output" \
            ./main
        
        tar czf "$output.tar.gz" "$output"
        rm -f "$output"
    done

# Push Docker image
docker-push:
    docker push {{organization}}/{{project_name}}:{{version}}

# Run Docker container
docker-run:
    docker run --rm -it {{organization}}/{{project_name}}:{{version}}

# Database operations
db-migrate:
    #!/usr/bin/env sh
    if [ -d "migrations" ]; then
        go run -tags 'postgres mysql' github.com/golang-migrate/migrate/v4/cmd/migrate@latest \
            -database "${DATABASE_URL}" \
            -path migrations up
    else
        echo "⚠️  No migrations directory found"
    fi

db-rollback:
    go run -tags 'postgres mysql' github.com/golang-migrate/migrate/v4/cmd/migrate@latest \
        -database "${DATABASE_URL}" \
        -path migrations down 1

db-reset:
    go run -tags 'postgres mysql' github.com/golang-migrate/migrate/v4/cmd/migrate@latest \
        -database "${DATABASE_URL}" \
        -path migrations drop -f

# Generate documentation
docs:
    mkdir -p {{docs_dir}}
    {{go}} doc -all > {{docs_dir}}/API.md

# Show version information
version:
    @echo "Version:    {{version}}"
    @echo "Commit:     {{git_commit}}"
    @echo "Branch:     {{git_branch}}"
    @echo "Built:      {{build_time}}"
    @echo "Built by:   {{build_by}}"
    @echo "Go version: $({{go}} version)"
