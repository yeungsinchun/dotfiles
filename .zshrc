typeset -U path PATH
path=(
  # CLI tools
  $HOME/.cargo/bin
  $HOME/.opencode/bin
  $HOME/.local/bin
  $PNPM_HOME

  # Homebrew
  /opt/homebrew/bin
  /opt/homebrew/opt/llvm/bin

  # Personal
  $HOME/Documents/path
  $HOME/.npm-global/lib/node_modules

  # Apps
  /Applications/Inkscape.app/Contents/MacOS

  # Course / lab
  $HOME/Documents/UST/COMP4121/clp-lab05/bin/macos

  # Android (ANDROID_HOME from ~/.env)
  $ANDROID_HOME/emulator
  $ANDROID_HOME/platform-tools

  # Languages / math
  $HOME/.juliaup/bin
  $HOME/Library/SageMath-10-7/bin
  $JAVA_HOME/bin

  # TeX
  /usr/local/texlive/2022/bin/universal-darwin

  $path
)
export PATH

# source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
# source /opt/homebrew/opt/chruby/share/chruby/auto.sh
# chruby ruby-3.1.3 # run chruby to see actual version

# Google Cloud SDK
if [ -f "$HOME/dev/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/dev/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/dev/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/dev/google-cloud-sdk/completion.zsh.inc"; fi

# Lazy-load conda (replaces conda init block for faster startup)
# If you run `conda init zsh` again, remove the duplicate block it adds.
conda() {
  unset -f conda
  local __conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  elif [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
    . "/opt/anaconda3/etc/profile.d/conda.sh"
  else
    export PATH="/opt/anaconda3/bin:$PATH"
  fi
  unset __conda_setup
  if [ -n "$CONDA_PREFIX" ] && [ -d "$CONDA_PREFIX/bin" ]; then
    path=($CONDA_PREFIX/bin ${path:#$CONDA_PREFIX/bin})
    export PATH
  fi
  conda "$@"
}

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

function _update_ps1()
{
    export PROMPT="$(python ~/dev/powerline-zsh/powerline-zsh.py $?)"
}
precmd()
{
	_update_ps1
}
# export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
# export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"

# Lazy-load nvm
lazy_load_nvm() {
  unset -f nvm node npm npx lazy_load_nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
nvm()  { lazy_load_nvm; nvm "$@"; }
node() { lazy_load_nvm; node "$@"; }
npm()  { lazy_load_nvm; npm "$@"; }
npx()  { lazy_load_nvm; npx "$@"; }

# opam
[[ ! -r "$HOME/.opam/opam-init/init.zsh" ]] || source "$HOME/.opam/opam-init/init.zsh" > /dev/null 2> /dev/null

[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env"

alias cursor='/Applications/Cursor.app/Contents/MacOS/Cursor'

# >>> juliaup initialize >>>
# !! Contents within this block are managed by juliaup !!
# juliaup bin is in the PATH block above; only completions here
[ -f "$HOME/.julia/juliaup/completions/zsh.zsh" ] && source "$HOME/.julia/juliaup/completions/zsh.zsh"
# <<< juliaup initialize <<<
