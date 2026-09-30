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
    skills-mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };

    # 外部 sub agent の取得元
    agents-voltagent = {
      url = "github:VoltAgent/awesome-claude-code-subagents";
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
