#!/bin/env sh

if [ $# -gt 0 ]; then
  exec /usr/bin/emacsclient --no-wait --alternate-editor= --reuse-frame "$@"
else
  exec /usr/bin/emacsclient --no-wait --alternate-editor= --create-frame
fi
