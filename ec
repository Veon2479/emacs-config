#!/bin/env sh

if [ $# -gt 0 ]; then
  GTK_THEME=Breeze exec /usr/bin/emacsclient --no-wait --alternate-editor= --reuse-frame "$@"
else
  GTK_THEME=Breeze exec /usr/bin/emacsclient --no-wait --alternate-editor= --create-frame
fi
