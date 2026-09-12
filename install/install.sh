#!/bin/bash

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# browser
brew install --cask google-chrome
brew install --cask microsoft-edge
brew install --cask firefox
brew install --cask thebrowsercompany-dia

brew install --cask docker
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

# mise
brew install mise
mise use -g node@lts
mise use -g npm:pnpm
mise use -g npm:npm-check-updates
mise use -g npm:@antfu/ni
mise use -g npm:cspell

# cspell: link the shared personal dictionary as global config
cspell link add "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/cspell.json"

# login items: macOS起動時に自動起動させるアプリ
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Vicinae.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/AeroSpace.app", hidden:false}'
