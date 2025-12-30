# Auto-attach to tmux
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    while true; do
        if [ "$(tmux list-sessions 2>/dev/null | wc -l)" -gt 1 ]; then
            # Multiple sessions - show picker
            tmux attach \; choose-tree -s
        else
            tmux attach 2>/dev/null || tmux new -s main
        fi
    done
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#757575'

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Override prompt to use blue instead of cyan for directory
PROMPT='%{$fg_bold[red]%}➜ %{$fg_bold[blue]%}%c%{$reset_color%} $(git_prompt_info)'

export PATH="$PATH:$HOME/.composer/vendor/bin"
export PATH="$PATH:$HOME/.config/composer/vendor/bin"
export PATH="$PATH:$HOME/.bin"
export PATH="$PATH:$HOME/.local/bin"

# OS
alias nz="nvim ~/.zshrc"
alias lz="lazygit"
alias yeet="sudo rm -rf"
alias vim="nvim"
alias nv="nvim"
alias mkd="mkdir -p"
alias sourcez="source ~/.zshrc"

# Hyprland
alias wbr='pkill waybar; hyprctl dispatch exec waybar &>/dev/null'

# Tmux
alias tks="tmux kill-server"
alias ts="tmux source ~/.tmux.conf"

# Laravel (DDEV)
alias a="ddev artisan"
alias solo="a solo"
alias pam="a migrate"
alias pamf="a migrate:fresh"
alias pamfs="a migrate:fresh --seed"

# Laravel Test
alias test="clear && a test"
alias tp="clear && a test -p"
alias tf="clear && a test --filter"

# Laravel Vendor
alias dust="ddev exec ./vendor/bin/duster fix"
alias duster="ddev exec ./vendor/bin/duster"
alias pint="ddev exec ./vendor/bin/pint"
alias pail="a pail"
alias stan="ddev exec ./vendor/bin/phpstan analyse"
alias pest="ddev exec ./vendor/bin/pest"

# Filament
alias fu="a make:filament-user"
alias frg="a make:filament-resource --generate"
alias res="a make:filament-resource"
alias fp="a make:filament-page"
alias frm="a make:filament-relation-manager"

# NPM
alias watch="npm run watch"
alias prod="npm run production"
alias dev="npm run dev"
alias build="npm run build"

# Python
alias python="python3"
alias pip="pip3"
