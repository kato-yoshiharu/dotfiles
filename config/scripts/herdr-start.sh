#!/bin/bash
if [[ -z "$HERDR_ENV" ]]; then
  SESSION_NAME=$(basename "$(pwd)")
  if herdr session list | awk 'NR>1 {print $1}' | grep -q "^$SESSION_NAME$"; then
    herdr session attach "$SESSION_NAME"
  else
    herdr --session "$SESSION_NAME"
  fi
fi
