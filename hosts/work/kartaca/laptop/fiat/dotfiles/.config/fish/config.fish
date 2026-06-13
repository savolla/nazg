# environment
set fish_greeting
set -x _JAVA_AWT_WM_NONREPARENTING 1
set -x GOOGLE_APPLICATION_CREDENTIALS "$HOME/.config/gcloud/legacy_credentials/kuzey.koc@kartaca.com/adc.json"
set -x FZF_DEFAULT_OPTS --height=10% --preview-window=top,1,wrap --preview-window=border-none --no-list-border --no-input-border --reverse --ansi "--bind=esc:abort" "--bind=tab:accept" "--bind=ctrl-space:toggle+down"
set -U fish_history_limit 10000000
set -x GPG_TTY (tty) # make sure gpg agent promts you in terminal when needed

# settings for using GPG as SSH authentication
set -e SSH_AGENT_PID
if not set -q gnupg_SSH_AUTH_SOCK_by; or test "$gnupg_SSH_AUTH_SOCK_by" -ne $fish_pid
    set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
end

# aliases
alias kubectl="kubecolor"
alias r="ranger"
alias f="clear"
alias clar="clear"
alias cler="clear"
alias claer="clear"
alias x="exit"
alias b="cd .."
alias cd="z"
alias pg="ping gnu.org"
alias sxiv="nsxiv"
alias ls="exa --icons --git"
alias ncdu="gdu"

function __ga
    # Build file list with status prefix and ANSI colors
    set file_list (
        git status --porcelain |
        awk '
            # Staged (index modified)
            /^[MARC][ MD]/ { printf "\033[32mS %s\033[0m\n", $2 }
            # Unstaged (worktree modified)
            /^[ MARC][MD]/ { printf "\033[31mM %s\033[0m\n", $2 }
            # Untracked
            /^\?\?/        { printf "\033[90mU %s\033[0m\n", $2 }
        '
    )

    test -z "$file_list" && echo "Nothing to stage." && return 0

    set selected (
        printf '%s\n' $file_list |
        fzf -m \
            --ansi \
            --preview '
                status=$(echo {} | sed "s/\x1b\[[0-9;]*m//g" | cut -d" " -f1)
                file=$(echo {} | sed "s/\x1b\[[0-9;]*m//g" | cut -d" " -f2-)
                if [ "$status" = "S" ]; then
                    git diff --cached --color=always -- "$file"
                elif git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
                    git diff --color=always -- "$file"
                else
                    bat --style=numbers --color=always "$file" 2>/dev/null || cat "$file"
                fi
            ' \
            --preview-window=right:60%:wrap
    ) || return 1

    # Sort selected files into stage / unstage buckets
    set to_stage
    set to_unstage

    for entry in $selected
        set clean (string replace -ra '\x1b\[[0-9;]*m' '' -- $entry)
        set status_code (string split " " $clean)[1]
        set filepath (string join " " (string split " " $clean)[2..])

        if test "$status_code" = S
            set to_unstage $to_unstage $filepath
        else
            set to_stage $to_stage $filepath
        end
    end

    # Build command string
    set cmd_parts
    if test (count $to_unstage) -gt 0
        set cmd_parts $cmd_parts "git restore --staged -- $to_unstage"
    end
    if test (count $to_stage) -gt 0
        set cmd_parts $cmd_parts "git add -- $to_stage"
    end

    set final_cmd (string join " && " $cmd_parts)
    echo $final_cmd
end

# abbrs
abbr -a k kubectl
abbr -a --set-cursor --position anywhere G '| rg -i "%"'
abbr -a --set-cursor --position anywhere A "| awk '{ print \$% }'"
abbr -a --set-cursor --position anywhere S "| sed 's/%//g'"
abbr -a --set-cursor --position anywhere B "| bat -l %"
abbr -a --set-cursor --position anywhere W "| wc -l %"
abbr -a c qalc -i
abbr -a ga --function __ga

# cursor
set fish_cursor_default block
set fish_cursor_insert block
set fish_cursor_replace_one block
set fish_cursor_visual block

# fzf history search
function fzf_history_search
    set current_input (commandline)
    set selected (history | awk '!seen[$0]++' | fzf --query="$current_input")
    test -z "$selected" && commandline -f repaint && return
    commandline --replace "$selected"
    commandline -f repaint
end

# legolas
fish_add_path --path $HOME/project/repos/legolas-cli

## for Ctrl+f
function __legolas
    set cmd (legolas)
    test -z "$cmd" && return
    commandline --replace "$cmd"
    commandline --cursor (string length "$cmd")
end

## for fish abbreviations to work
function _legolas_register_abbr
    set -l token $argv[1]
    function __legolas_$token --inherit-variable token
        legolas --abbr $token # stdout becomes the expanded text
    end
    abbr -a $token --function __legolas_$token
end

for abbr_token in (legolas --list-abbrs 2>/dev/null)
    _legolas_register_abbr $abbr_token
end

# key bindings
function fish_user_key_bindings
    fish_vi_key_bindings # ← add this; initializes insert/normal modes
    bind -M insert \cr fzf_history_search
    bind -M normal \cr fzf_history_search
    bind -M insert \cf '__legolas; commandline -f repaint'
    bind -M normal \cf '__legolas; commandline -f repaint'
    bind -M insert \cl accept-autosuggestion
    bind -M insert \ck clear-screen
end

# done plugin settings
set -U __done_min_cmd_duration 1800000 # notify if process finished after 30 mins
set -U __done_notify_sound 1 # play sound when process finishes
set -U __done_notification_urgency_level normal
set -U __done_notification_urgency_level_failure critical
set -U __done_notification_duration -1 # never expire the notification

# init
zoxide init fish | source
starship init fish | source
# source /home/$USER/.nix-profile/etc/profile.d/nix.fish
