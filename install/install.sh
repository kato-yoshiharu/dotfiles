#!/bin/bash

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# browser
brew install --cask google-chrome
brew install --cask microsoft-edge
brew install --cask firefox
brew install --cask thebrowsercompany-dia

brew install --cask docker
brew install --cask karabiner-elements
brew install --cask nikitabobko/tap/aerospace
brew install --cask raycast
brew install --cask tableplus
brew install --cask vicinae
brew install --cask visual-studio-code
brew install --cask wezterm
brew install --cask zoom

brew install aws-cdk
brew install gh
brew install zoxide
brew install fzf
brew install fd
# yazi の S（中身検索）と、シェル単体での grep 置き換えに使う
brew install ripgrep
brew install yazi
brew install neovim
# nvim-treesitter の main ブランチがパーサのコンパイルに使う
brew install tree-sitter-cli
brew install tmux
brew install xh
brew install lazysql
brew install posting
brew install rumdl
brew install pipx
pipx install sqlit-tui
pipx inject sqlit-tui psycopg2-binary

# mise
brew install mise
mise use -g node@lts
mise use -g npm:pnpm
mise use -g npm:npm-check-updates
mise use -g npm:@antfu/ni
mise use -g npm:cspell

# cspell: link the shared personal dictionary as global config
# グローバル辞書は cspell-global worktree の cspell.json だけを編集する運用にしている。
# そのため、リンク先は常にこの worktree に固定する。
CSPELL_GLOBAL_DIR="$HOME/development/suimenkathemove/dotfiles-worktrees/cspell-global"
CSPELL_GLOBAL_JSON="$CSPELL_GLOBAL_DIR/cspell.json"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# worktree がなければ作成する。
# ブランチが既にあれば -b なしで、なければ origin/main から作る。
if [ ! -d "$CSPELL_GLOBAL_DIR" ]; then
  if git -C "$DOTFILES_DIR" show-ref --verify --quiet refs/heads/cspell-global; then
    git -C "$DOTFILES_DIR" worktree add "$CSPELL_GLOBAL_DIR" cspell-global
  else
    git -C "$DOTFILES_DIR" worktree add "$CSPELL_GLOBAL_DIR" -b cspell-global origin/main
  fi
fi

# 別の dotfiles の cspell.json へのリンクが残っていれば外す（冪等にするため）。
cspell link list | awk -F' *\\| *' '{print $4}' | grep '/dotfiles.*/cspell\.json$' | while read -r linked; do
  if [ "$linked" != "$CSPELL_GLOBAL_JSON" ]; then
    cspell link remove "$linked"
  fi
done

cspell link add "$CSPELL_GLOBAL_JSON"

# login items: macOS起動時に自動起動させるアプリ
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Vicinae.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/AeroSpace.app", hidden:false}'
