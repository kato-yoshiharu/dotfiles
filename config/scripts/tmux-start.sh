#!/bin/bash

CURRENT_DIR="$(basename "$(pwd)")"
SESSION_NAME="${1:-$CURRENT_DIR}"
tmux a -t "$SESSION_NAME" || tmux new -s "$SESSION_NAME"
