# Show notification
#
# Dependence:
# * Mac OS X: terminal-notifier
#
# Usage:
# notify message [title]

function _notify-echo() {
  local msg
  msg=""
  [[ "x$2" != "x" ]] && msg+="$2: "
  msg+="$1"
  echo $msg
}

function _notify-terminal-notifier() {
  local args
  args=(-message "$1")
  [[ "x$2" != "x" ]] && args+=(-title "$2")
  terminal-notifier $args >/dev/null 2>&1
}

alias notify=_notify-echo
case `uname -s` in
  Darwin)
    if [[ $(whence terminal-notifier) != "" ]]; then
      alias notify=_notify-terminal-notifier
    fi
    ;;
esac
