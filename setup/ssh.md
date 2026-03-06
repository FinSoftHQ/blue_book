### How to setup SSH for GitHub

**1. Generate the keys with your custom names:**

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_varobol
ssh-keygen -t ed25519 -f ~/.ssh/id_finsoft

```

**2. Update your `~/.ssh/config` to match:**
You must ensure the `IdentityFile` line points to the exact filename you created.

```text
# Varobol Account
Host github.com-varobol
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_varobol

# FinSoftHQ Account
Host github.com-finsoft
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_finsoft

```

---

### Two things to remember:

1. **The Public Key:** When you upload the key to GitHub, you need the content of the `.pub` file (e.g., `cat ~/.ssh/id_finsoft.pub`). Don't ever share or upload the file without the `.pub` extension—that’s your private key!
2. **Permissions:** If you create these files manually, SSH might complain if the permissions are too "open." You can fix this by running:

```bash
chmod 600 ~/.ssh/id_varobol ~/.ssh/id_finsoft

```

---

### Quick Setup using script

You shall also run the following script to setup the ssh keys and config file:

```bash
curl -fsSL https://raw.githubusercontent.com/FinSoftHQ/blue_book/refs/heads/main/setup/copy_ssh.sh | bash
```