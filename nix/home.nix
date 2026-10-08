{ lib, pkgs, inputs, ... }:
let
  # 自作 skill は .agents/skills 直下のディレクトリを全て有効にする。
  localSkills = lib.attrNames (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir ../.agents/skills)
  );

  # 自作 sub agent は claude/agents 直下の *.md をファイル単位で配置する。
  localAgents = lib.mapAttrs' (name: _: {
    name = ".claude/agents/${name}";
    value.source = ../claude/agents/${name};
  }) (
    lib.filterAttrs (
      name: type: type == "regular" && lib.hasSuffix ".md" name
    ) (builtins.readDir ../claude/agents)
  );

  # 外部 sub agent は flake input（flake = false）から1ファイルずつ指定する。
  externalAgents = {
    ".claude/agents/VoltAgent/awesome-claude-code-subagents/code-reviewer.md".source =
      "${inputs.agents-voltagent}/categories/04-quality-security/code-reviewer.md";
    ".claude/agents/alirezarezvani/devils-advocate.md".source =
      "${inputs.agents-alirezarezvani}/c-level-advisor/executive-mentor/agents/devils-advocate.md";
  };
in
{
  home.username = "katouyoshiharu";
  home.homeDirectory = "/Users/katouyoshiharu";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = [
    pkgs.ccusage
    inputs.backlog-md.packages.${pkgs.system}.default
  ];

  home.file = localAgents // externalAgents;

  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  programs.agent-skills = {
    enable = true;

    sources = {
      local.path = ../.agents/skills;
      mattpocock-skills = {
        input = "skills-mattpocock-skills";
        subdir = "skills/productivity";
      };
      mattpocock-skills-engineering = {
        input = "skills-mattpocock-skills";
        subdir = "skills/engineering";
      };
      claude-plugins-community-eli5 = {
        input = "skills-claude-plugins-community";
        subdir = "eli5/skills";
      };
      natural-japanese = {
        input = "skills-natural-japanese";
        subdir = "skills";
      };
      yomiyasu = {
        input = "skills-yomiyasu";
        subdir = "skills";
      };
      i-have-adhd = {
        input = "skills-i-have-adhd";
        subdir = "skills";
      };
      vercel-agent-skills = {
        input = "skills-vercel-agent-skills";
        subdir = "skills";
      };
      vercel-skills = {
        input = "skills-vercel-skills";
        subdir = "skills";
      };
    };

    # yomiyasu は subdir = "skills" 配下で発見された ID で有効にする。
    skills.enable = localSkills ++ [ "yomiyasu" ];
    skills.explicit = {
      # 上流のフォルダ名は react-best-practices だが、
      # SKILL.md の name は vercel-react-best-practices である。
      # 配置名を name に合わせるため、キーは name の方にする。
      vercel-react-best-practices = {
        from = "vercel-agent-skills";
        path = "react-best-practices";
      };
      find-skills = {
        from = "vercel-skills";
        path = "find-skills";
      };
      grilling = {
        from = "mattpocock-skills";
        path = "grilling";
      };
      grill-me = {
        from = "mattpocock-skills";
        path = "grill-me";
      };
      domain-modeling = {
        from = "mattpocock-skills-engineering";
        path = "domain-modeling";
      };
      grill-with-docs = {
        from = "mattpocock-skills-engineering";
        path = "grill-with-docs";
      };
      eli5 = {
        from = "claude-plugins-community-eli5";
        path = "eli5";
      };
      natural-japanese = {
        from = "natural-japanese";
        path = "natural-japanese";
      };
      i-have-adhd = {
        from = "i-have-adhd";
        path = "i-have-adhd";
      };
    };

    # link は宛先ディレクトリ全体を置き換えて既存の ~/.claude/skills と衝突するため、symlink-tree にする。
    targets.claude = {
      enable = true;
      structure = "symlink-tree";
    };
    targets.agents = {
      enable = true;
      structure = "symlink-tree";
    };
  };
}
