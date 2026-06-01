if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Lines configured by zsh-newuser-install
setopt IGNORE_EOF # prevent accidental tmux window closes by ignoring Ctrl+d keybinding
export TERM=xterm-256color # for ssh sessions to work properly
export _JAVA_AWT_WM_NONREPARENTING=1 # for soapui and other java apps to render properly on dwm
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/legacy_credentials/kuzey.koc@kartaca.com/adc.json" # for terraform+gcp auth
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH" # for kubectl krew package manager
export PATH="$HOME/.local/bin:$PATH"
# export FZF_DEFAULT_OPTS="--select-1 --exit-0" # auto select option if there's only one left
export GOPATH="$HOME/.local/go"
export PATH="$PATH:$GOPATH/bin"

PATH="$HOME/project/scripts/linux/:$PATH" # add my personal scripts to the path
HISTFILE=~/.zsh-history
HISTSIZE=9999999
SAVEHIST=9999999
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS # remove duplicate commands
setopt EXTENDED_HISTORY # save timestamp in history

KEYTIMEOUT=1
bindkey -v
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char # without this, zsh vi mode will not delete chars
bindkey "^L" autosuggest-accept
bindkey "^P" up-history
bindkey "^N" down-history
 
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/kkoc/.zshrc'

# enable auto completions (vital for kubectl serverside completions)
autoload -Uz compinit
compinit
# End of lines added by compinstall

# aliases
alias r="ranger"
alias f="clear"
alias clar="clear"
alias cler="clear"
alias claer="clear"
alias x="exit"
alias b="cd .."
alias pg="ping gnu.org"
alias sxiv="nsxiv"
alias ls="exa --icons --git"
#alias emacs="~/.config/emacs/bin/doom run"
alias ncdu="gdu"
alias srm="secure-rm"
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias cd="z"

# nix/nixos
alias home.switch.kartaca.personal-laptop.fiat="home-manager switch --flake  $HOME/project/repos/one-ring#kartaca."personal-laptop".fiat"

# activate plugins
source ~/.nix-profile/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.nix-profile/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
# source /nix/store/n4h4jdhxndjaqk63fgmigcibsk63hvsd-zsh-abbr-6.2.1/share/zsh/zsh-abbr/zsh-abbr.plugin.zsh

# kubernetes settings
source <(kubectl completion zsh) # add kubectl auto completions
alias k="kubectl"
alias kubectl="kubecolor"

# start zoxide
eval "$(zoxide init zsh)"

# start starship
eval "$(starship init zsh)"

if [ -e /home/kkoc/.nix-profile/etc/profile.d/nix.sh ]; then . /home/kkoc/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

fzf_history_widget() {
  local key selected

  # get unique commands (latest first)
  local history_list
  history_list=$(
    fc -rl 1 |
    awk '{ $1=""; sub(/^[ \t]+/, ""); if (!seen[$0]++) print $0 }'
  )

  # Run fzf without preview
  local fzf_output
  fzf_output=$(
    echo "$history_list" |
    FZF_DEFAULT_OPTS="--height 40% \
                      --reverse \
                      --ansi \
                      --bind 'esc:abort' \
                      --bind 'tab:accept' \
                      --expect=enter" \
    fzf --query="${LBUFFER}"
  )

  # Parse key and selected command
  key=$(head -n 1 <<< "$fzf_output")
  selected=$(tail -n +2 <<< "$fzf_output")

  # Abort cleanly if ESC or nothing selected
  if [[ -z "$selected" ]]; then
    zle redisplay
    return
  fi

  # Execute or insert
  if [[ "$key" == "enter" ]]; then
    BUFFER="$selected"
    zle accept-line   # run immediately
  else
    LBUFFER="$selected"
    zle redisplay
  fi
}

zle -N fzf_history_widget
bindkey '^S' fzf_history_widget

function pet-select() {
  BUFFER=$(pet search --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle redisplay
}
zle -N pet-select
stty -ixon
bindkey '^R' pet-select

cc() {
  local dir
  dir=$(
    find $HOME -type d -name .git -prune -o -type d -print 2>/dev/null |
    sed 's|^\./||' |
    fzf --height 40% \
        --reverse \
        --ansi \
        --bind 'esc:abort' \
        --bind 'tab:accept'
  )

  if [[ -n "$dir" ]]; then
    cd "$dir" || return
  fi
}

ff() {
  local file
  file=$(
    find $HOME -type d -name .git -prune -o -type f -print 2>/dev/null |
    sed 's|^\./||' |
    fzf --height 40% \
        --reverse \
        --ansi \
        --preview 'bat --style=plain --color=always {} 2>/dev/null || cat {}' \
        --bind 'esc:abort' \
        --bind 'tab:accept'
  )

  if [[ -n "$file" && -f "$file" ]]; then
    nvim "$file"
  fi
}

function prev() {
  PREV=$(fc -lrn | head -n 1)
  sh -c "pet new -t `printf %q "$PREV"`"
}

# kartaca aliases
function servers() {
    local SERVERFILE="$HOME/project/repos/gimly/servers"
    local ENVNAMES=("pretest" "test" "staging" "prod")

    if [[ $1 == "ssh" ]]; then
        window_name=$(echo "$2-$3" | sed 's/ /-/g')
        tmux-cssh -n $window_name -c "$(grep -iE "$2.*$3" $SERVERFILE | awk '{print $1}')"
        return 1
    else
        grep -iE "$1.*$2" $SERVERFILE --color=always
    fi
    echo -e "\nCount: "
}

# run through your shell history
# eval "$(mcfly init zsh)"
# eval "$(mcfly-fzf init zsh)"
export PATH=/home/kkoc/.local/bin:$PATH

security-update () {
    ENV=$1
    LOG_DIR=~/project/kartaca/hopi/logs/ansible/security-updates
    ANSIBLE_DIR=~/project/kartaca/hopi/repos/bird-usy/ansible
    echo "Usage: security-update <pretest, test, staging, production>"
    ansible-playbook -i $ANSIBLE_DIR/hosts -l $ENV -kK $ANSIBLE_DIR/update_pkgs.yml | tee -a $LOG_DIR/$ENV-security-updates-`date '+%Y-%m-%d'`.log
}
