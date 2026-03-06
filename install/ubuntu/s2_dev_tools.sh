#!/bin/bash
set -e # Exit on error

### Setup Node and NPM using LTS version
pnpm env use -g lts

### Kimi Code (from https://www.kimi.com/code/docs/en/kimi-cli/guides/getting-started.html#installation)
curl -LsSf https://code.kimi.com/install.sh | bash

### Open Code (from https://opencode.ai/docs#install)
curl -fsSL https://opencode.ai/install | bash