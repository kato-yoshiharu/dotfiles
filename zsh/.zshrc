# starship
eval "$(starship init zsh)"

# mise
eval "$(mise activate zsh)"

# .commands
alias hello-world="sh ~/.commands/hello-world.sh"
alias tmux-start="sh ~/.commands/tmux-start.sh"

# herdr
sh ~/.commands/herdr-start.sh

# direnv
eval "$(direnv hook zsh)"

# local settings (not committed)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

export PATH="$HOME/.local/bin:$PATH"

herdr() {
  sh ~/.commands/herdr.sh "$@"
}
