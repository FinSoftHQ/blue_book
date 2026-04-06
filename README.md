# blue_book
Enterprise-wide Conventions for FinSoft 2023

## Quick Ubuntu setup

Use the following commands on Ubuntu to download and run the setup scripts from the repository.

Step 1 - Update the machine:

```bash
curl -fsSL https://raw.githubusercontent.com/FinSoftHQ/blue_book/refs/heads/main/install/ubuntu/s1_machine_update.sh | bash
```

Step 2 - Install developer tools:

```bash
curl -fsSL https://raw.githubusercontent.com/FinSoftHQ/blue_book/refs/heads/main/install/ubuntu/s2_dev_tools.sh | bash
```

### NOTE:

You might need to call the following script to refresh the shell:

```bash
source ~/.bashrc
```

After Step 2, you might need to run this command
```bash
pnpm approve-build -g --all
```

#### Login to GitHub CLI

You might need to login to GitHub CLI (gh, not github) using command:

```bash
gh auth login
```

## To Install Ubuntu on Windows via WSL2

You might use the following command to install Ubuntu (LTS) to WSL2 on Windows:

```bash
wsl --install Ubuntu-24.04 --name <machine_name> --location <file_location_on_non_C_disk>
```

For example,

```bash
wsl --install Ubuntu-24.04 --name DevUbuntu --location D:\wsl\DevUbuntu
```
