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
pnpm add -g @playwright/cli@latest
playwright-cli install

#### Install browser support for Playwright (NO Webkit)
sudo apt-get install libnspr4 libnss3 libxss1 libatk-bridge2.0-0 libgtk-3-0 libgbm1 libasound2t64

# Install D2 (from https://github.com/terrastruct/d2)
curl -fsSL https://d2lang.com/install.sh | sh -s --

### Agent Browser (from https://github.com/vercel-labs/agent-browser)
pnpm add -g agent-browser
agent-browser install --with-deps  # Download Chrome from Chrome for Testing (first time only)

### GitHub CLI (from https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian)
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

### Typst (from https://github.com/typst/typst)
cargo install --locked typst-cli

### Just (from https://github.com/casey/just?tab=readme-ov-file#cross-platform)
cargo install just

### Gemini CLI (from https://geminicli.com/docs/get-started/)
pnpm add -g @google/gemini-cli

### Pi (from https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent)
pnpm add -g @mariozechner/pi-coding-agent

### Build those dependencies needed
# echo "Setting up pnpm global builds..."
# pnpm approve-build -g --all
