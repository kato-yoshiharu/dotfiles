{ lib, excludedSkills }:
let
  # 自作 skill は config/coding-agents/skills 直下のディレクトリを全て有効にする。
  localSkills = lib.attrNames (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir ../config/coding-agents/skills)
  );

  # 自動検出する skill は source ごとに列挙し、source の除外判定にも使う。
  enabledSkillSources = [
    { name = "local"; value = localSkills; }
    { name = "yomiyasu"; value = [ "yomiyasu" ]; }
    { name = "explainer"; value = [ "explainer" "explainer-book" "first-reader" "d2-diagram" "d2-slides" ]; }
    { name = "walkinglabs-learn-harness-engineering"; value = [ "harness-creator" ]; }
  ];
  enabledSkillsBySource = builtins.listToAttrs enabledSkillSources;
  enabledSkills = lib.concatMap (source: source.value) enabledSkillSources;

  # 自動検出に任せない skill は source と path を明示する。
  explicitSkills = {
    # 上流のフォルダ名は react-best-practices だが、
    # SKILL.md の name に合わせて配置する。
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
    archify.input = "skills-archify";
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

  # flake input にすると除外判定より前に取得される。
  # そのため、外部 skill source は個別に固定する。
  externalInputPinsRaw = {
    skills-addyosmani-agent-skills = {
      type = "github";
      owner = "addyosmani";
      repo = "agent-skills";
      rev = "aeac41d4d005999432bb7312f7ff06383a91d59d";
      narHash = "sha256-HxaYbxuZwVo2wybYazM05YUJG/udQNQP6X0qA5wfYIs=";
    };
    skills-affaan-m-ecc = {
      type = "github";
      owner = "affaan-m";
      repo = "ECC";
      rev = "76aaa77df6adc5b889e689007bf99b9a4f74af34";
      narHash = "sha256-miKnVmpSSRg98RFu2sep/ZFZVBFvytJ9co+F2ggwuFE=";
    };
    skills-archify = {
      type = "github";
      owner = "tt-a1i";
      repo = "archify";
      rev = "b25142deac4b19b293e45b6bf6d69351d3c8f3b6";
      narHash = "sha256-B9ZeGFHHGXEk5eFK3T5D0G1IBlK3Kw8auEycRKUQDCE=";
    };
    skills-claude-plugins-community = {
      type = "github";
      owner = "anthropics";
      repo = "claude-plugins-community";
      rev = "06ec7b6a0a82bdc4bec44bd82d4368c42f20d7c1";
      narHash = "sha256-tHCAXZmHANA0gTQ8KO+DPAzapX5I+Ok1q1+COD720+A=";
    };
    skills-claude-plugins-official = {
      type = "github";
      owner = "anthropics";
      repo = "claude-plugins-official";
      rev = "ea10b213686c90bb1984b2016937310e05336cf3";
      narHash = "sha256-Tfs8Ig1rzLvaAuTZwqGUzKCK0TMWE2SddYss+H/04ug=";
    };
    skills-explainer = {
      type = "github";
      owner = "mizchi";
      repo = "explainer";
      rev = "ccdd7bacfb47451e38506d837af8a629504960b2";
      narHash = "sha256-XY4wnEtw3regcnDZ4BDZEM/a3jQ6jraSfkf+CPAH1v4=";
    };
    skills-i-have-adhd = {
      type = "github";
      owner = "ayghri";
      repo = "i-have-adhd";
      rev = "1ecea1993b7fce257ffbd686c070948b5e07eda6";
      narHash = "sha256-GTqrnZxQvzo/ogAuUrffkOaMK1BYm/4rAZsnfmDt7DU=";
    };
    skills-mattpocock-skills = {
      type = "github";
      owner = "mattpocock";
      repo = "skills";
      rev = "49dd158d1076134a641b33efb035946536778336";
      narHash = "sha256-NljCSZNI3sZ+vbCw7pRdrwR7try4BxOFp4gdjuWYtzs=";
    };
    skills-natural-japanese = {
      type = "github";
      owner = "coji";
      repo = "natural-japanese";
      rev = "03bc944a0c4a9f0b2a66eab065b30de5c529bf08";
      narHash = "sha256-Il7tG4edqjf/nBNOo0QXPztFmH4MwjHf0g5nVL+IWAY=";
    };
    skills-vercel-agent-skills = {
      type = "github";
      owner = "vercel-labs";
      repo = "agent-skills";
      rev = "063bee94c3f4df8453406c830b0a7df0f2860278";
      narHash = "sha256-tTSJf53OQltUfxTH4hdqcnw5ywCjCZP8/JqQ593cyB8=";
    };
    skills-vercel-skills = {
      type = "github";
      owner = "vercel-labs";
      repo = "skills";
      rev = "13e4063a1cf913f5606d57d42ab83a86f5001e04";
      narHash = "sha256-djzSciYX530uc1Xk4+Vdf2IHmNotC0bb6YU/peF0UK4=";
    };
    skills-walkinglabs-learn-harness-engineering = {
      type = "github";
      owner = "walkinglabs";
      repo = "learn-harness-engineering";
      rev = "38ddcd2bf8d65271f668b94e7c875ca1d629d622";
      narHash = "sha256-MzIGR9UMQcoqu0DE0SDHExJfaSy9917xr1QxjyBidMA=";
    };
    skills-yomiyasu = {
      type = "github";
      owner = "nanaism";
      repo = "yomiyasu";
      rev = "84e1f5b15e497538fcfe19ab7e9c6f6d138f19ff";
      narHash = "sha256-cvZgUFMYWVJ2yuYmbDCR+jzO9n2qEOiDU++VfKPi1c8=";
    };
  };

  # source と skill の対応は、自動検出と明示指定の定義から組み立てる。
  sourceSkills = lib.foldlAttrs (
    result: name: skill:
    result // { ${skill.from} = (result.${skill.from} or [ ]) ++ [ name ]; }
  ) enabledSkillsBySource explicitSkills;
  externalInputNames = lib.unique (
    map (source: source.input) (
      lib.attrValues (lib.filterAttrs (_: source: source ? input) sources)
    )
  );
  missingExternalInputPins = lib.filter (
    name: !(builtins.hasAttr name externalInputPinsRaw)
  ) externalInputNames;
  unusedExternalInputPins = lib.filter (
    name: !(builtins.elem name externalInputNames)
  ) (lib.attrNames externalInputPinsRaw);
  externalInputPins =
    if missingExternalInputPins != [ ] then
      throw "外部 skill source の pin がない: ${lib.concatStringsSep ", " missingExternalInputPins}"
    else if unusedExternalInputPins != [ ] then
      throw "使われていない外部 skill source の pin がある: ${lib.concatStringsSep ", " unusedExternalInputPins}"
    else
      externalInputPinsRaw;
  knownSkills = lib.unique (lib.concatLists (lib.attrValues sourceSkills));
  unknownExcludedSkills = lib.filter (name: !(builtins.elem name knownSkills)) excludedSkills;
  validatedExcludedSkills =
    if unknownExcludedSkills == [ ] then excludedSkills
    else throw "EXCLUDED_SKILLS に未知の skill ID がある: ${lib.concatStringsSep ", " unknownExcludedSkills}";

  # EXCLUDED_SKILLS に指定した skill は有効にしない。
  isSkillEnabled = name: !(builtins.elem name validatedExcludedSkills);

  # 有効な skill がない source は取得しない。
  isSourceEnabled = name: lib.any isSkillEnabled sourceSkills.${name};
  enabledSources = lib.filterAttrs (name: _: isSourceEnabled name) sources;
  enabledExternalInputNames = lib.unique (
    map (source: source.input) (
      lib.attrValues (lib.filterAttrs (_: source: source ? input) enabledSources)
    )
  );
in
{
  inherit enabledExternalInputNames enabledSkills enabledSources explicitSkills externalInputPins isSkillEnabled;
}
