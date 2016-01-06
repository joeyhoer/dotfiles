# Load default zprofile for non-login shells
[[ ! -o login ]] && [[ -e /etc/zprofile ]] && source /etc/zprofile

# Load antigen
source $HOME/.antigen/antigen.zsh

# Load the oh-my-zsh's library (`lib`)
antigen use oh-my-zsh

# Load bundles
antigen bundle git
antigen bundle vagrant
antigen bundle terminalapp
antigen bundle zsh_reload
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-syntax-highlighting
# antigen bundle powerline/powerline powerline/bindings/zsh

# Load theme
antigen theme $HOME/.antigen/themes joeyhoer-powerline

# Apply changes
antigen apply

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,zsh_prompt,exports,exports_secure,aliases,functions,extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# wp-cli completion
# NOTE: Must appear after `antigen apply`
if hash wp; then
  autoload -U +X bashcompinit && bashcompinit
  antigen bundle wp-cli/wp-cli utils/wp-completion.bash
fi

# n98-magerun completion
hash n98-magerun.phar 2>/dev/null && antigen bundle netz98/n98-magerun autocompletion/zsh
