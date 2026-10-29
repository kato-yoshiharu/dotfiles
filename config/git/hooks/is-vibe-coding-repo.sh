#!/bin/sh
# infra repo の vibe_coding_repositories.tf に定義されていれば 0 を返す。

tf="${GHQ_ROOT:-$HOME/repos}/github.com/kato-yoshiharu/infra/github/vibe_coding_repositories.tf"
[ -f "$tf" ] || exit 1

url=$(git remote get-url origin 2>/dev/null) || exit 1
slug=$(printf '%s' "$url" | sed -E 's#^(https://github\.com/|git@github\.com:|ssh://git@github\.com/)##; s#\.git$##')
[ "${slug%%/*}" = kato-yoshiharu ] || exit 1
repo=${slug#*/}

awk -v repo="$repo" '
  $1 == "name" && $2 == "=" { gsub(/"/, "", $3); if ($3 == repo) found = 1 }
  END { exit !found }
' "$tf"
