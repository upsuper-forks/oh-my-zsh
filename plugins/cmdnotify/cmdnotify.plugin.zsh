# Show notification when a command runs long than a given time
#
# Reference:
# * http://blog.tobez.org/posts/how_to_time_command_execution_in_zsh/
#
# Dependence:
# * plugin notify of oh-my-zsh

zmodload zsh/datetime
zmodload zsh/mathfunc

CMDNOTIFY_TIME=5
CMDNOTIFY_IGNORE_PREFIX=(time sudo tsocks)
CMDNOTIFY_DONT_NOTIFY=(man)
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
    if [[ $difftime -ge $CMDNOTIFY_TIME && $TTYIDLE -ge $CMDNOTIFY_TIME ]]; then
      last_cmd=(${(Q)${(z)_CMDNOTIFY_LAST_CMD}})
      # filter env vars
      for prog in $last_cmd
        [[ \
          "$prog" != [[:graph:]]*=[[:graph:]]* && \
          "$prog" != ";" && \
          "${CMDNOTIFY_IGNORE_PREFIX[(r)$prog]}" != "$prog" ]] \
          && break

      # human-readable time delta
      let "minute = int(difftime / 60)"
      let "second = difftime - minute * 60"
      let "hour = int(minute / 60)"
      let "minute -= hour * 60)"
      let "day = int(hour / 24)"
      let "hour -= day * 24"

      time_text=
      [[ "$day" != "0" ]] && time_text+=$(printf "%dd" $day) && second=0
      [[ "$hour" != "0" ]] && time_text+=$(printf "%dh" $hour)
      [[ "$minute" != "0" ]] && time_text+=$(printf "%dm" $minute)
      if [[ "$time_text" == "" ]]; then
        time_text=$(printf "%.1fs" $second)
      elif [[ "$(( int(second) ))" != "0" ]]; then
        time_text+=$(printf "%ds" $second)
      fi

      [[ "${CMDNOTIFY_DONT_NOTIFY[(r)$prog]}" != "$prog" ]] && \
        notify "$_CMDNOTIFY_LAST_CMD" \
            "'$(basename $prog)' ($time_text)"
    fi
  fi
}

add-zsh-hook  preexec _cmdnotify-preexec
add-zsh-hook  precmd  _cmdnotify-precmd
