.PHONY: init install-nix setup agent-configs switch

# 導入直後のシェルは PATH に nix が無いため、switch でも補う。
NIX_BIN := /nix/var/nix/profiles/default/bin

init: install-nix switch setup

# nix が無いときだけ Determinate Nix Installer で導入する。
# 導入時に管理者パスワードを求められる。
# 導入後に switch などで失敗して同じシェルでやり直したとき、
# 未導入と誤判定して再導入しないよう、判定の前に NIX_BIN を PATH に足す。
install-nix:
	@PATH="$(NIX_BIN):$$PATH"; \
	if command -v nix >/dev/null 2>&1; then \
		echo "nix は導入済み"; \
	else \
		curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm; \
	fi

setup:
	sh setup/setup.sh

# ベースに Orca など他のツールの hooks を引き継いで merge し、~/.claude/settings.json と ~/.codex/hooks.json の実ファイルを更新する。
agent-configs:
	config/scripts/build-agent-configs.sh

# 初回は flakes が無効なので、NIX_CONFIG で有効にする。
# --extra-experimental-features は home-manager 内部の nix に引き継がれない。
# home-manager への引数は ARGS で渡す。例: make switch ARGS="-b bak"
switch: agent-configs
	PATH="$(NIX_BIN):$$PATH" \
	NIX_CONFIG='experimental-features = nix-command flakes' \
	DOTFILES_DIR="$$(git rev-parse --show-toplevel)" \
	nix run home-manager -- switch --flake ".#$$USER" --impure $(ARGS)
