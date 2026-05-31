# dotfiles

Cross-machine dotfiles managed with [chezmoi](https://www.chezmoi.io). One repo,
two machines (a macOS laptop on `zsh` and an Ubuntu workstation on `bash`), with
per-machine templating and age-encrypted secrets.

## Layout

Source files use chezmoi's naming (`dot_` → `.`, `_dot_` inside dirs, `.tmpl`
templated, `encrypted_` age-encrypted, `private_` mode 600):

| Source | Target | Notes |
| --- | --- | --- |
| `dot_zshrc` | `~/.zshrc` | macOS only (ignored elsewhere) |
| `dot_bashrc` | `~/.bashrc` | workstation only |
| `dot_config/shell/common.sh` | `~/.config/shell/common.sh` | aliases shared by both shells |
| `dot_config/nvim/` | `~/.config/nvim/` | Neovim + `lazy-lock.json` (pinned plugins) |
| `dot_config/{tmux,zellij,starship.toml}` | `~/.config/...` | |
| `dot_config/{btop,nushell}/` | `~/.config/...` | workstation only |
| `dot_gitconfig`, `dot_ackrc`, `dot_ctags`, `dot_ignore`, `dot_vimrc` | `~/.*` | |
| `encrypted_private_dot_secrets.age` | `~/.secrets` | age-encrypted; sourced by both shells |

Per-machine behavior lives in `.chezmoiignore` and `.chezmoi.toml.tmpl`
(keyed on `.chezmoi.os` / `.chezmoi.hostname`).

## Secrets

Tokens are **never** stored in plaintext in the repo. `~/.secrets` is
age-encrypted to both machines' public keys and decrypted on `apply`. Each
machine's age **private** key lives at `~/.config/chezmoi/key.txt`
(gitignored, never committed). The decrypted `~/.secrets` activates only the
relevant secrets per OS, and both shells `source` it.

Edit secrets with: `chezmoi edit ~/.secrets` (decrypts, opens, re-encrypts on save).

## Daily workflow

```sh
chezmoi edit ~/.zshrc        # edit a managed file (opens the source)
chezmoi diff                 # preview pending changes to $HOME
chezmoi apply                # write changes to $HOME
chezmoi cd && git add -A && git commit && git push   # share
chezmoi update               # on the other machine: git pull + apply
```

After `:Lazy update` in Neovim, commit the refreshed lock:
`chezmoi add ~/.config/nvim/lazy-lock.json` then commit.

> On the Mac the source dir is this repo (`~/dev/setup/dotfiles`); on other
> machines it is chezmoi's default (`~/.local/share/chezmoi`).

## Bootstrapping a new machine

1. Install chezmoi, age, and Neovim (≥ 0.11).
2. Create the age key: `age-keygen -o ~/.config/chezmoi/key.txt`, then add its
   **public** key to `recipients` in `.chezmoi.toml.tmpl` and re-encrypt
   `~/.secrets` so the new machine can decrypt.
3. `chezmoi init --apply https://github.com/ericperez-01/dotfiles.git`
4. In Neovim, `:Lazy restore` to install plugins at the locked versions.

## Neovim

- Plugin manager: `lazy.nvim` (auto-bootstrapped in `init.lua`).
- AI (`avante.nvim`) targets a local **Qwen** served by vLLM via the
  OpenAI-compatible API. Endpoint comes from `$VLLM_ENDPOINT`
  (`localhost:8000` on the workstation, `workstation:8000` over Tailscale on the
  Mac), with a fallback baked into `lua/regular.lua`.
- `flash.nvim` for motion (labeled `f/F/t/T`, rainbow distance labels).
