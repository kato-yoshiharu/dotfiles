.PHONY: init setup switch

init: switch setup

setup:
	sh setup/setup.sh

# 初回は flakes が無効なので、NIX_CONFIG で有効にする。
# --extra-experimental-features は home-manager 内部の nix に引き継がれない。
# home-manager への引数は ARGS で渡す。例: make switch ARGS="-b bak"
switch:
	NIX_CONFIG='experimental-features = nix-command flakes' \
	DOTFILES_DIR="$$(git rev-parse --show-toplevel)" \
	nix run home-manager -- switch --flake ".#$$(whoami)" --impure $(ARGS)
