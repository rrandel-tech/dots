# -----------------------------
# GPG / SSH
# -----------------------------

# Set GPG_TTY to current TTY
if [ -n "$TTY" ]; then
  export GPG_TTY=$(tty)
else
  export GPG_TTY="$TTY"
fi

# Use gpg-agent as SSH agent
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

# Fix for password store
export PASSWORD_STORE_GPG_OPTS='--no-throw-keyids'

# -----------------------------
# Nix
# -----------------------------
if [ -f '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# -----------------------------
# PATH
# -----------------------------
export PATH="/usr/local/bin:/usr/bin:$PATH"
export LD_LIBRARY_PATH=/usr/local/lib

# -----------------------------
# OS-Specific Profiles
# -----------------------------
if [ "$(uname)" = "Darwin" ] && [ -f "$HOME/.profile-macos" ]; then
  source "$HOME/.profile-macos"
fi

if [ "$(uname)" = "Linux" ] && [ -f "$HOME/.profile-linux" ]; then
  source "$HOME/.profile-linux"
fi

# -----------------------------
# Zinit Plugin Manager
# -----------------------------

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit if missing
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Community plugins
autoload -Uz compinit && compinit

zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light Aloxaf/fzf-tab

zinit cdreplay -q

# -----------------------------
# Completion Styling
# -----------------------------
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# -----------------------------
# Locale
# -----------------------------
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# -----------------------------
# General Shell Behavior
# -----------------------------
setopt auto_cd

# History search with arrows
bindkey -e
bindkey -v
bindkey '^p'  history-search-backward
bindkey '^n'  history-search-forward
bindkey '^h'    backward-kill-word
bindkey '^[w' kill-region

# Disable paste highlighting
zle_highlight=('paste:none')

# -----------------------------
# Tmuxinator
# -----------------------------
# source "$HOME/.profile"
# source "$HOME/.config/tmuxinator/tmuxinator.zsh"

# -----------------------------
# History
# -----------------------------
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# -----------------------------
# Wayland support
# -----------------------------
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  export MOZ_ENABLE_WAYLAND=1
fi

# -----------------------------
# Shell Integrations
# -----------------------------
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi

# -----------------------------
# Aliases
# -----------------------------
alias i="paru -S"
alias r="paru -Rns"
alias u="paru -Syu"
alias s="paru -Ss"
alias q="paru -Q"

alias ls="eza --icons --group-directories-first -l"

alias gc="git clone"

# -----------------------------
# Oh My Posh Prompt
# -----------------------------
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"

