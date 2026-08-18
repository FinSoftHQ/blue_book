#!/bin/bash
set -e # Exit on error

### Setup Node and NPM using LTS version
pnpm runtime set node lts -g

### Kimi Code (from https://www.kimi.com/code/docs/en/kimi-cli/guides/getting-started.html#installation)
curl -fsSL https://code.kimi.com/kimi-code/install.sh | bash

### Open Code (from https://opencode.ai/docs#install)
curl -fsSL https://opencode.ai/install | bash

### GitHub Copilot CLI (from https://github.com/features/copilot/cli)
curl -fsSL https://gh.io/copilot-install | bash

# Install D2 (from https://github.com/terrastruct/d2)
curl -fsSL https://d2lang.com/install.sh | sh -s --

### Agent Browser (from https://github.com/vercel-labs/agent-browser)
pnpm add -g --allow-build=agent-browser agent-browser
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
# pnpm add -g @google/gemini-cli

### Pi (from https://github.com/earendil-works/pi/tree/main/packages/coding-agent#quick-start)
# pnpm add -g @earendil-works/pi-coding-agent
curl -fsSL https://pi.dev/install.sh | sh

### Z-Code (from https://zcode.z.ai/en#all-downloads)
# Download the .deb package
wget https://cdn-zcode.z.ai/zcode/electron/releases/3.7.7/linux-x64/ZCode-3.7.7-linux-x64.deb

# Install with apt (auto-resolves dependencies)
sudo apt install -y ./ZCode-3.7.7-linux-x64.deb

rm ZCode-3.7.7-linux-x64.deb

### Goose (from https://goose-docs.ai/docs/quickstart#install-goose)
# curl -fsSL https://github.com/aaif-goose/goose/releases/download/stable/download_cli.sh | bash

### Context7 (from https://github.com/upstash/context7#installation)
pnpm add -g ctx7

### OhMyPi - omp (from https://github.com/can1357/oh-my-pi#install)
bun install -g @oh-my-pi/pi-coding-agent

# bash — add to ~/.bashrc
# eval "$(omp completions bash)"

### OpenSpec (from https://github.com/Fission-AI/OpenSpec#quick-start)
# pnpm add -g @fission-ai/openspec@latest

### Superpower (from https://github.com/obra/superpowers#opencode)
mkdir -p ~/.config/opencode && cat > ~/.config/opencode/opencode.json << 'EOF'
{
  "plugin": ["superpowers@git+https://github.com/obra/superpowers.git"]
}
EOF

### Visual Explainer (from https://github.com/nicobailon/visual-explainer#install)
pi install git:github.com/nicobailon/visual-explainer

### Pi-SubAgents (from https://pi.dev/packages/pi-subagents)
# pi install npm:pi-subagents

### Pi-Superpowers (from https://github.com/gadgj/pi-superpowers-support#installation)
omp install git:github.com/obra/superpowers

# 1. Install superpowers (official)
pi install git:github.com/obra/superpowers

# 2. Install pi-subagents (for Task/Agent tool)
# pi install npm:@tintinweb/pi-subagents

# 3. This extension is auto-loaded from ~/.pi/agent/extensions/
# pi install npm:@uadgj/pi-superpowers-support

### Pi-GStack (from https://pi.dev/packages/pi-gstack?name=gstack)
# pi install npm:pi-gstack

### Build those dependencies needed [DEPRECATED]
echo "Setting up pnpm global builds..."
# pnpm approve-builds -g

### Install markitdown (from https://github.com/microsoft/markitdown)
# uv tool install markitdown[all]

### Install PDF-Inspector or pdf2md (from https://github.com/firecrawl/pdf-inspector#cli)
# Install the CLI tools
cargo install pdf-inspector

### Install GitNexus (from https://github.com/abhigyanpatwari/GitNexus)
# bun add -g gitnexus
# bun pm trust -g @ladybugdb/core onnxruntime-node tree-sitter tree-sitter-{c,c-sharp,cpp,go,java,javascript,kotlin,php,python,ruby,rust,typescript} sharp @scarf/scarf protobufjs

### Plannator (from https://github.com/backnotprop/plannotator)
# macOS / Linux / WSL
curl -fsSL https://plannotator.ai/install.sh | bash
#### Pi
# pi install npm:@plannotator/pi-extension
# omp install npm:@plannotator/pi-extension

### Code Graph (from https://github.com/colbymchenry/codegraph)
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh

# Windows (PowerShell)
#irm https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.ps1 | iex

### Install AionUI (from https://github.com/iOfficeAI/AionUi)
#wget https://github.com/iOfficeAI/AionUi/releases/download/v2.1.15/AionUi-2.1.15-linux-amd64.deb
#sudo apt install ./AionUi-2.1.15-linux-amd64.deb
#rm AionUi-2.1.15-linux-amd64.deb


### direnv (from https://direnv.net/docs/installation.html#from-binary-builds)
curl -sfL https://direnv.net/install.sh | bash

# Define the target file and the exact command to add
BASHRC_FILE="$HOME/.bashrc"
HOOK_COMMAND='eval "$(direnv hook bash)"'

echo "Configuring direnv for Bash..."

# Check if the hook is already present in the file
if grep -qF "$HOOK_COMMAND" "$BASHRC_FILE"; then
    echo "✅ The direnv hook is already present in $BASHRC_FILE."
else
    # Append to the very end of the file
    # Using >> ensures it goes to the bottom, after RVM, git-prompt, etc.
    echo "" >> "$BASHRC_FILE"
    echo "# Load direnv (Must be at the very end of the file)" >> "$BASHRC_FILE"
    echo "$HOOK_COMMAND" >> "$BASHRC_FILE"
    echo "✅ Successfully appended the direnv hook to the end of $BASHRC_FILE."
fi

# Remind the user to reload their shell
echo "🔄 To apply these changes immediately, run: source ~/.bashrc"

### Gstack - OpenCode (from https://github.com/garrytan/gstack#other-ai-agents)
# git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/gstack
# cd ~/gstack && ./setup --host opencode
# cd
