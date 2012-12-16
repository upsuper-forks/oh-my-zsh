# Show notification
#
# Dependence:
# * Mac OS X: terminal-notifier
#
# Usage:
# notify message [title]

function _notify-terminal-notifier() {
  local args
  args=(-message "$1")
  [[ "x$2" != "x" ]] && args+=(-title "$2")
  terminal-notifier $args >/dev/null 2>&1
}

case `uname -s` in
  Darwin)
    if [[ $(whence terminal-notifier) != "" ]]; then
      alias notify=_notify-terminal-notifier
    fi
    ;;
esac
