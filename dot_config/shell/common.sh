# ~/.config/shell/common.sh — shared aliases for bash + zsh.
# Sourced from both ~/.bashrc and ~/.zshrc (managed by chezmoi).

# micromamba / conda
alias mamba=micromamba
alias conda=micromamba
alias ma='mamba activate'
alias mi='mamba install -y'

# rsync copy (machine-specific `move` lives in each shell rc)
alias copy='rsync -avzh --progress'

# Modern `ls` via eza.
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons -F -H --group-directories-first --git -1'
fi
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Claude Code
alias cc='claude --dangerously-skip-permissions'

# DeepSeek Harness (dsh), the Claude Code budget fallback. Like cc: no arguments opens the
# interactive session (the web UI), arguments run one headless task and print the answer.
# The model — Qwen 3.8 on the workstation's vLLM, or GLM 5.3 Flash via OpenRouter — is picked
# in the UI's model menu and saved to ~/.dsh/settings.yaml, which headless turns follow too.
ds() {
  if [ $# -eq 0 ]; then
    dsh --profile web --port 3080
  else
    dsh --profile headless "$@"
  fi
}
