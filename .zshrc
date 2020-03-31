# Allow antibody plugin manager
source /usr/share/zsh/share/antigen.zsh

# Allow for sourcing git
source /usr/lib/zsh-git-prompt/zshrc.sh

# Install plugins
antigen bundle git
antigen bundle heroku
antigen bundle pip
antigen bundle lein
antigen bundle command-not-found
antigen bundle zdharma/fast-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-history-substring-search
antigen apply

# Ensure language is correct
export LANG=en_GB.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
 export EDITOR='mvim'
else
 export EDITOR='nvim'
fi

# Allow for autocomplete to be case insensitive
zstyle ':completion:*' matcher-list '' \
'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
'+l:|?=** r:|?=**'

# Initialize the autocompletion
autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit
eval "$(stack --bash-completion-script stack)"

# Include hidden files in autocomplete:
_comp_options+=(globdots)

# Search history
bindkey '^[[A' history-substring-search-up
bindkey '^Y' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^E' history-substring-search-down

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Timeout
export KEYTIMEOUT=1

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'

  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

# Initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
zle-line-init() {
    zle -K viins 
    echo -ne "\e[5 q"
}
zle -N zle-line-init

# Use beam shape cursor on startup.
echo -ne '\e[5 q'

# Use beam shape cursor for each new prompt.
preexec() { echo -ne '\e[5 q' ;}

# Switch directory using ranger
bindkey -s '^o' '. ranger\n'

# Customise the prompt
PROMPT='
%{$fg_bold[cyan]%}%n %{$reset_color%}%{$fg[blue]%}:: %{$fg_bold[green]%}%~%{$reset_color%}$(git_super_status)%{$reset_color%}
$ '

# Customise how git prompt is shown
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[blue]%}:: %{$fg[magenta]%}\uE0A0 "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SEPARATOR="%{$fg[blue]%} | "
ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[red]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[cyan]%}-"

# Configure autosuggestions
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=blue'
ZSH_AUTOSUGGEST_STRATEGY='completion'

# Alias termbin for easy pastes
alias tb="nc termbin.com 9999"
