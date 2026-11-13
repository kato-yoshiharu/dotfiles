{
  description = "dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    backlog-md = {
      url = "github:MrLesk/Backlog.md";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Claude Code プラグインの取得元
    plugins-cursor = {
      url = "github:cursor/plugins";
      flake = false;
    };
    plugins-openai-codex = {
      url = "github:openai/codex-plugin-cc";
      flake = false;
    };

    # 外部 sub agent の取得元
    agents-voltagent = {
      url = "github:VoltAgent/awesome-claude-code-subagents";
      flake = false;
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, nix-darwin, agent-skills, ... }:
    let
      system = "aarch64-darwin";
      # darwin-rebuild は sudo で動き、USER と HOME が root のものになる。
      # そのため、実ユーザーは PRIMARY_USER で受け取り、
      # ホームディレクトリはそこから組み立てる。
      # 環境変数を読むため、--impure が必要。
      username = builtins.getEnv "PRIMARY_USER";
      excludedSkills =
        let
          value = builtins.getEnv "EXCLUDED_SKILLS";
          names = map nixpkgs.lib.trim (nixpkgs.lib.splitString "," value);
        in
        nixpkgs.lib.unique (nixpkgs.lib.filter (name: name != "") names);
      excludedPackages =
        let
          value = builtins.getEnv "EXCLUDED_PACKAGES";
          names = map nixpkgs.lib.trim (nixpkgs.lib.splitString "," value);
        in
        nixpkgs.lib.unique (nixpkgs.lib.filter (name: name != "") names);
      excludedCasks =
        let
          value = builtins.getEnv "EXCLUDED_CASKS";
          names = map nixpkgs.lib.trim (nixpkgs.lib.splitString "," value);
        in
        nixpkgs.lib.unique (nixpkgs.lib.filter (name: name != "") names);
      # 外部 skill の source は npins で固定し、有効なものだけを取得する。
      skillConfig = import ./nix/skills.nix {
        inherit (nixpkgs) lib;
        inherit excludedSkills;
        pins = import ./npins;
      };
      # worktree 専用のホームディレクトリを試すときだけ、
      # HOME_DIR でホームディレクトリを差し替える。
      homeDirectory =
        let homeDir = builtins.getEnv "HOME_DIR";
        in if homeDir != "" then homeDir else "/Users/${username}";
    in
    {
      darwinConfigurations.default = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          home-manager.darwinModules.home-manager
          ./nix/darwin.nix
        ];
        specialArgs = {
          inputs = inputs // skillConfig.enabledExternalInputs;
          inherit username homeDirectory excludedSkills excludedPackages excludedCasks;
          # ストア外配置の参照先。
          dotfilesDir = builtins.getEnv "DOTFILES_DIR";
        };
      };
    };
}
