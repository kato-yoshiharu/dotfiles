{
  description = "dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
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

    # 外部 skill の取得元
    skills-vercel-agent-skills = {
      url = "github:vercel-labs/agent-skills";
      flake = false;
    };
    skills-vercel-skills = {
      url = "github:vercel-labs/skills";
      flake = false;
    };
    skills-natural-japanese = {
      url = "github:coji/natural-japanese";
      flake = false;
    };
    skills-yomiyasu = {
      url = "github:nanaism/yomiyasu";
      flake = false;
    };
    skills-mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };
    skills-i-have-adhd = {
      url = "github:ayghri/i-have-adhd";
      flake = false;
    };
    skills-archify = {
      url = "github:tt-a1i/archify";
      flake = false;
    };
    skills-explainer = {
      url = "github:mizchi/explainer";
      flake = false;
    };
    skills-claude-plugins-community = {
      url = "github:anthropics/claude-plugins-community";
      flake = false;
    };

    # 外部 sub agent の取得元
    agents-voltagent = {
      url = "github:VoltAgent/awesome-claude-code-subagents";
      flake = false;
    };
    agents-alirezarezvani = {
      url = "github:alirezarezvani/claude-skills";
      flake = false;
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, agent-skills, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations.katouyoshiharu = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          agent-skills.homeManagerModules.default
          ./nix/home.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };
    };
}
