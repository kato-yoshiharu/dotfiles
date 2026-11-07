{ lib, excludedSkills, pins }:
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

  # 外部 skill source は npins/sources.json で rev と hash を固定する。
  # pin は参照したときだけ取得されるため、有効な source の pin だけを渡す。
  # 更新は npins update で行う。
  externalInputNames = lib.unique (
    map (source: source.input) (
      lib.filter (source: source ? input) (lib.attrValues sources)
    )
  );
  missingPins = lib.filter (name: !(pins ? ${name})) externalInputNames;

  # source と skill の対応は、自動検出と明示指定の定義から組み立てる。
  sourceSkills = lib.foldlAttrs (
    result: name: skill:
    result // { ${skill.from} = (result.${skill.from} or [ ]) ++ [ name ]; }
  ) enabledSkillsBySource explicitSkills;
  knownSkills = lib.unique (lib.concatLists (lib.attrValues sourceSkills));
  unknownExcludedSkills = lib.filter (name: !(builtins.elem name knownSkills)) excludedSkills;
  validatedExcludedSkills =
    if unknownExcludedSkills != [ ] then
      throw "EXCLUDED_SKILLS に未知の skill ID がある: ${lib.concatStringsSep ", " unknownExcludedSkills}"
    else if missingPins != [ ] then
      throw "npins/sources.json に pin がない外部 skill source がある: ${lib.concatStringsSep ", " missingPins}"
    else
      excludedSkills;

  # EXCLUDED_SKILLS に指定した skill は有効にしない。
  isSkillEnabled = name: !(builtins.elem name validatedExcludedSkills);

  # 有効な skill がない source は取得しない。
  isSourceEnabled = name: lib.any isSkillEnabled sourceSkills.${name};
  enabledSources = lib.filterAttrs (name: _: isSourceEnabled name) sources;
  enabledExternalInputs = lib.genAttrs (lib.unique (
    map (source: source.input) (
      lib.filter (source: source ? input) (lib.attrValues enabledSources)
    )
  )) (name: pins.${name});
in
{
  inherit enabledExternalInputs enabledSkills enabledSources explicitSkills isSkillEnabled;
}
