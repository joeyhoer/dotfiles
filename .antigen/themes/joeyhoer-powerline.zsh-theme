# joeyhoer's Powerline Theme
# A Powerline-inspired theme for ZSH

################################################################################
## Segment drawing
## A few utility functions to make it easy and re-usable to
## draw segmented prompts

CURRENT_BG='NONE'
PS_SPACES=1
SEGMENT_SEPARATOR=''
# Rightwards black arrowhead 
# Rightwards arrowhead 
# Leftwards black arrowhead 
# Leftwards arrowhead 

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    if [[ $PS_SPACES != 0 ]]; then
      printf '%.0s ' $(seq 1 $PS_SPACES)
    fi
    echo -n "%{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  PS_SPACES=1
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# Spacer
prompt_spacer() {
  local bg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{$bg%} "
  fi
  CURRENT_BG=$1
  PS_SPACES=${2:-1}
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

################################################################################
## Prompt components
## Each component will draw itself, and hide itself if no information
## needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment yellow black "$USER@%m"
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment black yellow '%~'
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment black yellow "$symbols"
}

# Prompt character
prompt_char() {
  local char
  char='$'
  [[ $UID -eq 0 ]] && char="⚡"

  prompt_segment black yellow "$char"
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref dirty mode repo_path stcolor state
  repo_path=$(git rev-parse --git-dir 2>/dev/null)

  #behind=$(git rev-list ..@{u} | wc -l | xargs 2>/dev/null)
  #ahead=$(git rev-list @{u}.. | wc -l | xargs 2>/dev/null)

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(parse_git_dirty)

    # Get branch name or (short) HEAD commit hash
    ref=$(git symbolic-ref --short HEAD 2>/dev/null) || ref="➦ $(git rev-parse --short HEAD 2>/dev/null)"

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    # ◎ ◉ | ● ○ ◦ • ⦿
    # Has unstaged changes
    git diff-files --quiet 2>/dev/null || state=' ⦿'
    # Has staged changes
    git diff-index --quiet --cached HEAD 2>/dev/null || state=' ●'


    # Add dirty indicator
    stcolor='green'
    [[ -n $dirty ]] && stcolor='red'
    prompt_spacer $stcolor

    prompt_segment yellow black
    echo -n "${ref}${state}${mode}"
  fi
}

## Main prompt
build_prompt1() {
  prompt_context
  prompt_dir
  prompt_git
  prompt_end
}

build_prompt2() {
  RETVAL=$?
  prompt_char
  prompt_end
}

# Beware double quotes
PROMPT=$'%{%f%b%k%}$(build_prompt1)\n$(build_prompt2) '
