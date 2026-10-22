eval "$(/opt/homebrew/bin/brew shellenv)"

# 非対話のログインシェルでも、nix のコマンドを brew より優先する。
# /etc/zshrc は対話型のシェルでしか読まれないため、ここでも読み込む。
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# >>> Codex installer >>>
export PATH="$HOME/.local/bin:$PATH"
# <<< Codex installer <<<
