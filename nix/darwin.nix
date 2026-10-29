{ inputs, username, homeDirectory, dotfilesDir, ... }:
{
  system.primaryUser = username;
  system.stateVersion = 7;

  # 既存の /etc/nix/nix.conf と衝突させないため、nix 自体は管理に入れない。
  nix.enable = false;

  users.users.${username}.home = homeDirectory;

  # home-manager は nix-darwin のモジュールとして組み込む。
  # nixpkgs.config は home.nix 側で設定するため、useGlobalPkgs は使わない。
  home-manager = {
    extraSpecialArgs = { inherit inputs username homeDirectory dotfilesDir; };
    sharedModules = [ inputs.agent-skills.homeManagerModules.default ];
    users.${username} = import ./home.nix;
  };

  # GUI アプリ（cask）だけを置く。
  # CLI ツールは nix/home.nix の home.packages で入れる。
  # Homebrew 本体は Makefile の install-brew で入れる。
  homebrew = {
    enable = true;

    onActivation = {
      # 更新は意図したときだけ手動で行う。
      autoUpdate = false;
      upgrade = false;
      # 宣言にない cask があっても消さない。
      cleanup = "none";
    };

    taps = [
      "nikitabobko/tap"
      "stablyai/orca"
    ];

    casks = [
      # browser
      "firefox"
      "google-chrome"
      "microsoft-edge"

      # 開発
      "docker-desktop"
      "tableplus"
      "wezterm"

      # ADE・AI関連
      "chatgpt"
      "cursor"
      "grok-bot"
      "stablyai/orca/orca"
      "t3-code"

      # その他
      "nikitabobko/tap/aerospace"
      "capsomnia"
      "homerow"
      "karabiner-elements"
      "keycastr"
      "vicinae"
      "zoom"

      # config/wezterm/wezterm.lua が使うフォント
      "font-hack-nerd-font"
    ];

    # Mac App Store のアプリ。
    # 値はアプリの ID で、mdls -raw -name kMDItemAppStoreAdamID <アプリ> で調べる。
    masApps = {
      "LINE" = 539883307;
      "Mail+ for Gmail" = 1216244845;
      "Xcode" = 497799835;
    };
  };
}
