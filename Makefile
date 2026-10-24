.PHONY: init install-nix install-brew setup agent-configs switch switch-home

# 導入直後のシェルは PATH に nix が無いため、switch でも補う。
NIX_BIN := /nix/var/nix/profiles/default/bin

init: install-nix install-brew switch setup

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

# Homebrew 本体は nix-darwin では入らないので、switch の前に入れる。
# Apple Silicon は /opt/homebrew、Intel は /usr/local に入る。
install-brew:
	@if [ -x /opt/homebrew/bin/brew ] || [ -x /usr/local/bin/brew ]; then \
		echo "Homebrew は導入済み"; \
	else \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi

setup:
	sh setup/setup.sh

# ベースに Orca など他のツールの hooks を引き継いで merge し、~/.claude/settings.json と ~/.codex/hooks.json の実ファイルを更新する。
agent-configs:
	config/scripts/build-agent-configs.sh

# CLI ツール・設定（home-manager）と cask（homebrew）を、nix-darwin でまとめて反映する。
# darwin-rebuild は root で動くため、実ユーザーと PATH を sudo 越しに渡す。
# 初回は flakes が無効なので、NIX_CONFIG で有効にする。
# 初回は darwin-rebuild が PATH に無いので、nix run で起動する。
# darwin-rebuild への引数は ARGS で渡す。
switch: agent-configs
	sudo env PATH="$(NIX_BIN):$$PATH" \
	PRIMARY_USER="$$USER" \
	DOTFILES_DIR="$$(git rev-parse --show-toplevel)" \
	NIX_CONFIG='experimental-features = nix-command flakes' \
	nix run nix-darwin/master#darwin-rebuild -- switch --flake ".#default" --impure $(ARGS)

# 設定ファイル（home-manager）だけを、実行した worktree に切り替える。
# sudo と brew bundle を省くため、worktree で設定を試すときはこちらを使う。
switch-home: agent-configs
	@export PATH="$(NIX_BIN):$$PATH" \
		PRIMARY_USER="$$USER" \
		DOTFILES_DIR="$$(git rev-parse --show-toplevel)" \
		NIX_CONFIG='experimental-features = nix-command flakes'; \
	out="$$(nix build ".#darwinConfigurations.default.config.home-manager.users.$$USER.home.activationPackage" --impure --no-link --print-out-paths)" \
		&& "$$out/activate"
