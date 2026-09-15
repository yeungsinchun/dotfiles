# Powerlevel10k config matching the old powerline-zsh prompt: one line, powerline
# separators, current directory, git state, and last exit status. No extra fonts
# beyond the powerline glyphs that prompt already used (U+2B80 / U+2B81).
#
# Generated for this repo rather than `p10k configure`; `p10k configure` will
# overwrite this file if you run it.

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs status)
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

  # Compatible unicode; separators are the old vim-powerline glyphs.
  typeset -g POWERLEVEL9K_MODE=compatible
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=true
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=

  typeset -g POWERLEVEL9K_BACKGROUND=237
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='%244F\u2B81'
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='\u2B80'
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL='\u2B80'
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=

  ################################[ dir: current directory ]################################
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=237
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=250
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=250
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=254
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=false
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER='⋯'
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=false
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false

  ################################[ vcs: git status ]################################
  # Clean = light green / black; dirty = pink-red / white (powerline-zsh colors).
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=148
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=0
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=161
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=15
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=161
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=15
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=161
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND=15
  typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=237
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=244
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)
  typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'

  function my_git_formatter() {
    emulate -L zsh
    if [[ -n $P9K_CONTENT ]]; then
      typeset -g my_git_format=$P9K_CONTENT
      return
    fi

    local res
    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      res+=${VCS_STATUS_LOCAL_BRANCH//\%/%%}
    else
      res+='(Detached)'
      [[ -n $VCS_STATUS_COMMIT ]] && res+=" ${VCS_STATUS_COMMIT[1,8]}"
    fi
    (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${VCS_STATUS_COMMITS_BEHIND}⇣"
    (( VCS_STATUS_COMMITS_AHEAD )) && res+=" ${VCS_STATUS_COMMITS_AHEAD}⇡"
    (( VCS_STATUS_NUM_STAGED )) && res+=" +${VCS_STATUS_NUM_STAGED}"
    (( VCS_STATUS_NUM_UNSTAGED )) && res+=" !${VCS_STATUS_NUM_UNSTAGED}"
    (( VCS_STATUS_NUM_UNTRACKED )) && res+=" ?${VCS_STATUS_NUM_UNTRACKED}"
    [[ -n $VCS_STATUS_ACTION ]] && res+=" ${VCS_STATUS_ACTION}"
    typeset -g my_git_format=$res
  }
  functions -M my_git_formatter 2>/dev/null

  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter(0)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1

  ################################[ status: last exit status ]################################
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_OK=true
  typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=236
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=15
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='❄'
  typeset -g POWERLEVEL9K_STATUS_OK_CONTENT_EXPANSION=
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_BACKGROUND=236
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=15
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION='❄'
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_CONTENT_EXPANSION=
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=161
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=15
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='❄'
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_BACKGROUND=161
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=15
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION='❄'
  typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_BACKGROUND=161
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=15
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION='❄'

  (( ! $+functions[p10k] )) || p10k reload
}

typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
