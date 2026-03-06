#!/bin/bash
set -e  # Exit on any error

mkdir -p ~/.ssh  # -p prevents error if dir exists
cp -r /mnt/d/apps/.ssh/* ~/.ssh || { echo "Failed to copy SSH files"; exit 1; }
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_varobol ~/.ssh/id_finsoft 2>/dev/null || echo "Warning: Some key files not found"
# or
# chmod 600 ~/.ssh/id_ed25519
