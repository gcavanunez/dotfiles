# Initialize tools not already provided by the host's Bash configuration.
if command -v mise &>/dev/null && [[ ${MISE_SHELL:-} != bash ]]; then
  eval "$(mise activate bash)"
fi

if [[ ${TERM:-} != dumb ]] && command -v starship &>/dev/null && [[ ${STARSHIP_SHELL:-} != bash ]]; then
  eval "$(starship init bash)"
fi

if command -v zoxide &>/dev/null && ! declare -F __zoxide_z &>/dev/null; then
  eval "$(zoxide init bash)"
fi

if [[ -z ${BLE_VERSION:-} ]] && command -v fzf &>/dev/null && ! declare -F _fzf_search_completion &>/dev/null; then
  eval "$(fzf --bash)"
elif [[ -n ${BLE_VERSION:-} ]] && declare -F ble-import &>/dev/null; then
  ble-import -d integration/fzf-completion
  ble-import -d integration/fzf-key-bindings
fi

if command -v atuin &>/dev/null && [[ ${__atuin_initialized:-} != true ]]; then
  eval "$(atuin init bash)"
fi

[ -f ~/.config/bash/functions.bash ] && source ~/.config/bash/functions.bash
if [[ ${DOTFILES_BASH_ALIASES_LOADED:-} != 1 ]]; then
  [ -f ~/.config/bash/aliases.bash ] && source ~/.config/bash/aliases.bash
fi

if [[ -n ${BLE_VERSION:-} ]] && declare -F ble-attach &>/dev/null; then
  ble-attach
fi
