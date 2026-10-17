#!/bin/bash
if [[ -z "$ZELLIJ" ]]; then
  SESSION_NAME=$(basename $(pwd) | cut -c1-24)
  if zellij list-sessions --short | grep -q "^$SESSION_NAME$"; then
    zellij attach "$SESSION_NAME"
  else
    zellij --session "$SESSION_NAME"
  fi
fi
