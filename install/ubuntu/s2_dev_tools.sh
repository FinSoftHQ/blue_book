#!/bin/bash
set -e # Exit on error

### Setup Node and NPM using LTS version
pnpm env use -g lts

### Kimi Code (from https://www.kimi.com/code/docs/en/kimi-cli/guides/getting-started.html#installation)
curl -LsSf https://code.kimi.com/install.sh | bash

### Open Code (from https://opencode.ai/docs#install)
curl -fsSL https://opencode.ai/install | bash

### GitHub Copilot CLI (from https://github.com/features/copilot/cli)
curl -fsSL https://gh.io/copilot-install | bash

### Playwright-CLI (from https://github.com/microsoft/playwright-cli with little modification)
pnpm install -g @playwright/cli@latest
playwright-cli install

#### Install browser support for Playwright (NO Webkit)
sudo apt-get install libnspr4 libnss3 libxss1 libatk-bridge2.0-0 libgtk-3-0 libgbm1 libasound2t64

### Typst (from https://github.com/typst/typst)
cargo install --locked typst-cli
