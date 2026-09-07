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
# interactive session (the web UI, on its own port per model); arguments run one headless
# task and print the answer. The --patch picks the model the session starts on.
_dsh_on() {
  local patch="$HOME/.dsh/patches/$1.yml" port="$2"; shift 2
  if [ $# -eq 0 ]; then
    dsh --profile web --patch "$patch" --port "$port"
  else
    dsh --profile headless --patch "$patch" "$@"
  fi
}
dsv() { _dsh_on vllm 3080 "$@"; }   # Qwen 3.8 on the workstation's vLLM (wakes it)
dsg() { _dsh_on glm 3081 "$@"; }    # GLM 5.3 Flash via OpenRouter
