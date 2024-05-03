#!/bin/bash

#FUZZEL_IGNORED_BINDIRS=/usr/bin:/usr/bin/core_perl:/usr/bin/site_perl:/usr/bin/vendor_perl

exit_err() {
  echo "$1" >&2
  exit 1
}

is_bindir_enabled() {
  if [[ "${_ignored_bindirs[*]}" =~ "$1" ]]; then
    return 1
  fi
  return 0
}

_fuzzel_exec=fuzzel
if which fuzzel-launch &>/dev/null; then
  _fuzzel_exec=fuzzel-launch
fi

_ignored_bindirs=""
if [ -n "$FUZZEL_IGNORED_BINDIRS" ]; then
  _ignored_bindirs=($(echo $FUZZEL_IGNORED_BINDIRS | tr ':' '\n' | sort | uniq))
fi

_bindirs=($(echo $PATH | tr ':' '\n' | sort | uniq))

_lsdirs=()
for _bindir in "${_bindirs[@]}"; do
  if [ -d $_bindir ] && is_bindir_enabled $_bindir; then
    _lsdirs+=($_bindir)
  fi
done

if [ -n "$_lsdirs" ]; then
  _execfile="$(ls ${_lsdirs[@]} | sort | uniq | sed '/^$/d' | $_fuzzel_exec --dmenu)"

  [ -n "$_execfile" ] || { echo "No executable was selected!"; exit; }

  if which "$_execfile"; then
    exec "$_execfile"
  else
    exit_err "No executable: $_execfile"
  fi
else
  exit_err "Failed finding executables!"
fi
