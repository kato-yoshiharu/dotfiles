{ config, lib, pkgs, inputs, dotfilesDir, username, homeDirectory, ... }:
let
  # worktree の実ファイルを指すリンクにする（ストア外配置）。
  # 編集が switch なしで反映される。
  outOfStore = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/${path}";

  # 自作 skill は config/coding-agents/skills 直下のディレクトリを全て有効にする。
  localSkills = lib.attrNames (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir ../config/coding-agents/skills)
  );

  # 自作 sub agent は config/claude/agents 直下の *.md をファイル単位で配置する。
  localAgents = lib.mapAttrs' (name: _: {
    name = ".claude/agents/${name}";
    value.source = outOfStore "config/claude/agents/${name}";
  }) (
    lib.filterAttrs (
      name: type: type == "regular" && lib.hasSuffix ".md" name
    ) (builtins.readDir ../config/claude/agents)
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
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "25.05";

  assertions = [
    {
      assertion = dotfilesDir != "";
      message = "DOTFILES_DIR が未設定。make switch で実行する。";
    }
  ];

  # terraform は BUSL ライセンスで、nixpkgs では unfree 扱いになっている。
  # antigravity-cli・claude-code・cursor-cli は独自ライセンスのバイナリ配布で、unfree 扱いになっている。
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "antigravity-cli"
    "claude-code"
    "cursor-cli"
    "terraform"
  ];

  home.packages = [
    inputs.backlog-md.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.antigravity-cli
    pkgs.awscli2
    pkgs.ccusage
    pkgs.codex
    pkgs.cspell
    pkgs.cursor-cli
    # cursor は GUI ではなく cursor-agent を起動する。
    (pkgs.writeShellScriptBin "cursor" ''exec ${pkgs.cursor-cli}/bin/cursor-agent --trust "$@"'')
    pkgs.dotenvx
    pkgs.fd
    pkgs.fzf
    pkgs.gh
    pkgs.ghq
    pkgs.git
    pkgs.herdr
    pkgs.hunk
    pkgs.jq
    pkgs.lazysql
    # node などのランタイムは、プロジェクトごとにバージョンを合わせるため mise で入れる。
    pkgs.mise
    pkgs.neovim
    pkgs.ni
    pkgs.npm-check-updates
    pkgs.opencode
    pkgs.pipx
    pkgs.pnpm
    pkgs.posting
    pkgs.rclone
    # yazi の S（中身検索）と、シェル単体での grep 置き換えに使う
    pkgs.ripgrep
    pkgs.rumdl
    pkgs.sqlit-tui
    pkgs.starship
    pkgs.terraform
    # nvim-treesitter の main ブランチがパーサのコンパイルに使う
    pkgs.tree-sitter
    pkgs.uv
    pkgs.xh
    pkgs.yazi
    pkgs.zoxide
  ];

  home.file = localAgents // externalAgents // {
    # Claude Code と Codex で共有する hooks
    ".agents/hooks".source = outOfStore "config/coding-agents/hooks";

    # Claude Code
    ".claude/AGENTS.md".source = outOfStore "config/coding-agents/AGENTS.md";
    ".claude/keybindings.json".source = outOfStore "config/claude/keybindings.json";
    ".claude/output-styles/diagrams-first.md".source =
      outOfStore "config/claude/output-styles/diagrams-first.md";
    # settings.json は Orca が hooks を書き込むため置かず、make agent-configs が config/claude/settings.json をベースに merge する。
    ".claude/statusline-command.sh".source = outOfStore "config/claude/statusline-command.sh";

    # Codex
    # config.toml は Codex が実行時の状態も書き込むため置かず、手動で同期する。
    ".codex/AGENTS.md".source = outOfStore "config/coding-agents/AGENTS.md";
    # hooks.json も settings.json と同じ理由で置かず、make agent-configs が実ファイルに merge する。
    # ~/.codex/rules には Codex が承認したコマンドの default.rules を書くため、ファイル単位で置く。
    ".codex/rules/destructive.rules".source = outOfStore "config/codex/rules/destructive.rules";

    # Cursor
    ".cursor/rules".source = outOfStore "config/cursor/rules";
    ".cursor/plugins/local/cursor-team-kit" = {
      source = "${inputs.plugins-cursor}/cursor-team-kit";
      recursive = true;
    };
    ".cursor/plugins/local/thermos" = {
      source = "${inputs.plugins-cursor}/thermos";
      recursive = true;
    };

    # git
    ".gitconfig".source = outOfStore "config/git/.gitconfig";
    ".mailmap".source = outOfStore "config/git/.mailmap";

    # scripts
    ".scripts".source = outOfStore "config/scripts";

    # zsh
    ".zprofile".source = outOfStore "config/zsh/.zprofile";
    ".zshrc".source = outOfStore "config/zsh/.zshrc";
  };

  xdg.configFile."aerospace/aerospace.toml".source = outOfStore "config/aerospace/aerospace.toml";

  # core.excludesFile を指定していないため、git は既定の ~/.config/git/ignore を読む。
  xdg.configFile."git/ignore".source = outOfStore "config/git/.gitignore_global";
  # core.hooksPath から参照する。
  xdg.configFile."git/hooks".source = outOfStore "config/git/hooks";

  # ~/.config/herdr にはログやソケットも置かれるため、config.toml だけを置く。
  xdg.configFile."herdr/config.toml".source = outOfStore "config/herdr/config.toml";

  # Karabiner-Elements は保存時にファイル単位のリンクを壊すため、ディレクトリごと置く。
  xdg.configFile."karabiner".source = outOfStore "config/karabiner";

  xdg.configFile."mise/config.toml".source = outOfStore "config/mise/config.toml";

  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  # Neovim
  # rumdl が作る .rumdl_cache やテストを置かないよう、置くものを列挙する。
  xdg.configFile."nvim/CLAUDE.md".source = outOfStore "config/nvim/CLAUDE.md";
  xdg.configFile."nvim/init.lua".source = outOfStore "config/nvim/init.lua";
  xdg.configFile."nvim/lazy-lock.json".source = outOfStore "config/nvim/lazy-lock.json";
  xdg.configFile."nvim/lua".source = outOfStore "config/nvim/lua";

  xdg.configFile."rumdl/rumdl.toml".source = outOfStore "config/rumdl/rumdl.toml";

  xdg.configFile."vicinae/settings.json".source = outOfStore "config/vicinae/settings.json";

  xdg.configFile."wezterm/wezterm.lua".source = outOfStore "config/wezterm/wezterm.lua";

  xdg.configFile."yazi/init.lua".source = outOfStore "config/yazi/init.lua";

  # programs.claude-code では settings と marketplaces を使わない。
  # 使うと ~/.claude/settings.json を home-manager が書き、既存の設定と衝突する。
  programs.claude-code = {
    enable = true;
    plugins.pstack = "${inputs.plugins-cursor}/harness/pstack/claude-code";
    plugins.openai-codex ="${inputs.plugins-openai-codex}/plugins/codex";
  };

  programs.agent-skills = {
    enable = true;

    sources = {
      local.path = ../config/coding-agents/skills;
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
      archify = {
        input = "skills-archify";
      };
      # explainer-book は ../explainer を兄弟ディレクトリ経由で参照するため、
      # 同じ source から explainer 系をまとめて有効にする。
      explainer = {
        input = "skills-explainer";
        subdir = "skills";
      };
      walkinglabs-learn-harness-engineering = {
        input = "skills-walkinglabs-learn-harness-engineering";
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
      # ECC は巨大なモノレポなので、skills.explicit で選んだものだけを有効にする。
      affaan-m-ecc = {
        input = "skills-affaan-m-ecc";
        subdir = "skills";
      };
      claude-plugins-official-claude-code-setup = {
        input = "skills-claude-plugins-official";
        subdir = "plugins/claude-code-setup/skills";
      };
      addyosmani-agent-skills = {
        input = "skills-addyosmani-agent-skills";
        subdir = "skills";
      };
    };

    # yomiyasu は subdir = "skills" 配下で発見された ID で有効にする。
    skills.enable = localSkills ++ [
      "yomiyasu"
      "explainer"
      "explainer-book"
      "first-reader"
      "d2-diagram"
      "d2-slides"
      "harness-creator"
    ];
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
      archify = {
        from = "archify";
        path = "archify";
      };
      eval-harness = {
        from = "affaan-m-ecc";
        path = "eval-harness";
      };
      agent-eval = {
        from = "affaan-m-ecc";
        path = "agent-eval";
      };
      agentic-engineering = {
        from = "affaan-m-ecc";
        path = "agentic-engineering";
      };
      claude-automation-recommender = {
        from = "claude-plugins-official-claude-code-setup";
        path = "claude-automation-recommender";
      };
      context-engineering = {
        from = "addyosmani-agent-skills";
        path = "context-engineering";
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
