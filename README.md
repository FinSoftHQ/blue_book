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