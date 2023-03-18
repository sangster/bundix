{ lib
, callPackage
, ...
}:

# This function translates 'bundixEnv' arguments into those acceptable for
# 'nixpkgs#bundlerEnv'.
{ gemfile ? null
, lockfile ? null
, gemset ? null
, gemdir ? null
, groups ? null
, platform ? null
, system ? null # TODO
,  ...
}@args:
let
  inherit (lib) assertMsg;

  # Either the provided 'platform' or the one assumed from `system`.
  envPlatform =
    assert assertMsg (platform == null -> system != null)
      "bundixEnv: either platform or system must be specified";
    if platform != null
    then platform
    else callPackage ./assumePlatform.nix {} system;

  gemFiles = (callPackage ./. {}).bundlerFiles args;
  importedGemset = if builtins.typeOf gemFiles.gemset != "set"
    then import gemFiles.gemset
    else gemFiles.gemset;

  platformGemset = platform:
    assert platform != null;
    buildPlatformGemset {} platform importedGemset.dependencies;

  # Populate 'gemset' with 'deps' and all their transitive-dependencies,
  # selecting from those gems that belong to the named `platform`. Will fallback
  # to the ruby platform gem if there are not available for the named platform.
  buildPlatformGemset = gemset: platform: deps:
    if deps == []
    then gemset
    else let
      dep = builtins.head deps;
      rest = builtins.tail deps;
      gem = getGem platform dep;
      newGemset = gemset // { ${dep} = gem; };
      newDeps = rest ++ (builtins.filter (d: !(newGemset ? ${d})) (gem.dependencies or []));
    in buildPlatformGemset newGemset platform newDeps;

  getGem = platform: name:
    let
      platformGem = plat: lib.attrByPath ["platforms" plat name] null importedGemset;
      gem = platformGem platform;
    in
      if gem != null then gem else (platformGem "ruby");

  selectedGroups = if groups != null && !(builtins.elem "default" groups)
                   then groups ++ ["default"]
                   else groups;
in args // {
  inherit (gemFiles) gemfile lockfile;
  gemset = platformGemset envPlatform;
  groups = selectedGroups;
}
