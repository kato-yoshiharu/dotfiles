#!/bin/bash
set -e

expected="$1"

if [ -z "$expected" ]; then
  echo "usage: git cbn <branch name>" >&2
  exit 1
fi

current_branch_name=$(git branch | grep \* | cut -d ' ' -f2)

if [ "$expected" = "$current_branch_name" ]; then
  echo o
  git push -u origin HEAD
else
  echo x
  exit 1
fi
