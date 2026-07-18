# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# ls (eza if available)
if command -v eza &>/dev/null; then
  alias ls="eza"
  alias ll="eza -la -g --icons --git"
  alias lt="eza -la --tree --level=2"
  alias llt="eza -1 --icons --tree --git-ignore"
  alias lll="eza -Dl --icons --sort=created --time=created -r"
else
  alias ll="ls -la"
fi

# Git
alias gitconfig="nvim ~/.gitconfig"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gpl="git pull"
alias gco="git checkout"
alias gb="git branch"
alias gst="git stash"
alias gstp="git stash pop"
alias gdiff="git diff master | diffstat"
alias lines="git ls-files | xargs cat | wc -l"

# Docker
alias dc="docker compose"
alias dcx="docker compose exec -it app"
alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dcl="docker compose logs -f"
alias dps="docker ps"
alias lzd="lazydocker"

# Laravel
alias art="php artisan"
alias drt="docker compose exec -it app php artisan"
alias sail="./vendor/bin/sail"
alias takeout="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock --add-host=host.docker.internal:host-gateway -it tighten/takeout:latest"

# Tools
alias lg="lazygit"
alias gl="lazygit"
alias v="nvim"
alias c="claude"

# AWS
alias awsp="aws configure --profile"

# Mise
alias mup="mise upgrade -C ~"
alias mls="mise list"
alias mic="${EDITOR:-nvim} ~/.config/mise/config.toml"

# Archives
alias decompress="tar -xzf"

# Shell
if [ -n "$ZSH_VERSION" ]; then
  alias reloadshell="source \$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
  alias reloadshell="source \$HOME/.bashrc"
fi
alias editrc="nvim ~/dotfiles"
alias reloadtmux="tmux source \$HOME/.tmux.conf"
# Refresh tmux server's PATH from a fresh shell (no kill needed). Useful after `mise upgrade`.
alias tmux-sync-env="tmux set-environment -g PATH \"\$(zsh -ic 'echo -n \$PATH')\""
alias tsc="\${EDITOR:-nvim} ~/.config/tmux-sessionizer/tmux-sessionizer.conf"
alias copyssh="pbcopy < \$HOME/.ssh/id_ed25519.pub"
alias search="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
