wrapsource=`which virtualenvwrapper_lazy.sh`

if [[ -f "$wrapsource" ]]; then
  if [[ -d $HOME/.virtualenvs ]]; then
    export VIRTUAL_ENV_DISABLE_PROMPT=1
    source $wrapsource
  fi
fi
