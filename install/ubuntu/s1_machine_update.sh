#!/bin/bash
set -e # Exit on error

sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential curl wget git pkg-config libssl-dev

### PNPM (from https://pnpm.io/installation)
curl -fsSL https://get.pnpm.io/install.sh | sh -

### UV (from https://docs.astral.sh/uv/getting-started/installation/)
curl -LsSf https://astral.sh/uv/install.sh | sh

### Rust (from https://rust-lang.org/tools/install/)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

### Install Unzip (for bun)
sudo apt install -y unzip

### Bun (from https://bun.com/)
curl -fsSL https://bun.sh/install | bash
