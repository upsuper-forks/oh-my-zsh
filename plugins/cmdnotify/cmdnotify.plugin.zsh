# Show notification when a command runs long than a given time
#
# Reference:
# * http://blog.tobez.org/posts/how_to_time_command_execution_in_zsh/
#
# Dependence:
# * plugin notify of oh-my-zsh

zmodload zsh/datetime

CMDNOTIFY_TIME=10
_CMDNOTIFY_EXECUTED=""

function _cmdnotify-preexec() {
  if [[ "x$TTY" != "x" ]]; then
    _CMDNOTIFY_START_TIME=$EPOCHREALTIME
    _CMDNOTIFY_LAST_CMD="$2"
    _CMDNOTIFY_EXECUTED="yes"
  fi
}

function _cmdnotify-precmd() {
  local difftime last_cmd prog
  if [[ -n "$TTY" && -n "$_CMDNOTIFY_EXECUTED" ]]; then
    _CMDNOTIFY_EXECUTED=""
    difftime=$(($EPOCHREALTIME-$_CMDNOTIFY_START_TIME))
    if [[ $difftime > $CMDNOTIFY_TIME && $TTYIDLE > $CMDNOTIFY_TIME ]]; then
      last_cmd=(${(Q)${(z)_CMDNOTIFY_LAST_CMD}})
      # filter env vars
      for prog in $last_cmd
        [[ $prog != [[:graph:]]*=[[:graph:]]* ]] && break
      notify "$_CMDNOTIFY_LAST_CMD" \
        "'$prog' ($(printf "%.1fs\n" $difftime))"
    fi
  fi
}

add-zsh-hook  preexec _cmdnotify-preexec
add-zsh-hook  precmd  _cmdnotify-precmd
