{ lib, pkgs, ... }:
let
  # 自作 skill は .agents/skills 直下のディレクトリを全て有効にする。
  localSkills = lib.attrNames (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir ../.agents/skills)
  );
in
{
  home.username = "katouyoshiharu";
  home.homeDirectory = "/Users/katouyoshiharu";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = [ pkgs.ccusage ];

  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  programs.agent-skills = {
    enable = true;

    sources = {
      local.path = ../.agents/skills;
      natural-japanese = {
        input = "skills-natural-japanese";
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

    skills.enable = localSkills;
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
      natural-japanese = {
        from = "natural-japanese";
        path = "natural-japanese";
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
