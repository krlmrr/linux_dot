# Auto-attach to tmux
if [[ -o interactive ]] && command -v tmux &> /dev/null && [ -z "$TMUX" ] && [ -t 0 ]; then
    exec tmux new-session -A -s main
fi

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Override prompt to use blue instead of cyan for directory
PROMPT='%{$fg_bold[red]%}➜ %{$fg_bold[blue]%}%c%{$reset_color%} $(git_prompt_info)'

# Add local bin and composer to PATH
export PATH="$HOME/.local/bin:$HOME/.config/composer/vendor/bin:$PATH"


# Aliases
alias tks="tmux kill-server"
alias ts="tmux source ~/.tmux.conf"
alias wbr='pkill waybar; hyprctl dispatch exec waybar &>/dev/null'
alias a="ddev exec php artisan"

