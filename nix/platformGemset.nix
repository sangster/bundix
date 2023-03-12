{ lib
, bundlerEnv
, callPackage
, ...
}:

{ gemfile ? null
, lockfile ? null
, gemset ? null
, gemdir ? null
, platform ? null
, system ? null # TODO
,  ...
}@args:
let
  inherit (lib) assertMsg;

  envPlatform =
    assert assertMsg (platform == null -> system != null)
      "bundixEnv: either platform or system must be specified";
    if platform != null
    then platform
    else callPackage ./assumePlatform.nix {} system;

  importedGemset = if builtins.typeOf gemFiles.gemset != "set"
    then import gemFiles.gemset
    else gemFiles.gemset;
  gemFiles = bundlerFiles args;

  # TODO: Can this be imported?
  # https://github.com/NixOS/nixpkgs/blob/48e4e2a1/pkgs/development/ruby-modules/bundled-common/functions.nix
  bundlerFiles =
    { gemfile ? null
    , lockfile ? null
    , gemset ? null
    , gemdir ? null
    , ...
    }: {
      inherit gemdir;
      gemfile =
        if gemfile == null then assert gemdir != null; gemdir + "/Gemfile"
        else gemfile;
      lockfile =
        if lockfile == null then assert gemdir != null; gemdir + "/Gemfile.lock"
        else lockfile;
      gemset =
        if gemset == null then assert gemdir != null; gemdir + "/gemset.nix"
        else gemset;
    };

  platformGemset = platform:
    assert platform != null;
    buildPlatformGemset {} [platform] importedGemset.dependencies;

  buildPlatformGemset = gemset: platforms: deps:
    if deps == []
    then gemset
    else let
      dep = builtins.head deps;
      rest = builtins.tail deps;
      gem = platformGem dep platforms;
      newGemset = gemset // { ${dep} = gem; };
      newDeps = rest ++ (builtins.filter (d: !(newGemset ? ${d})) gem.dependencies);
    in buildPlatformGemset newGemset platforms newDeps;

  platformGem = name: platforms:
    let
      platform = builtins.head platforms;
      gem = getGem platform name;
      fallback = getGem "ruby" name;
      rest = platformGem name (builtins.tail platforms);
    in
      if platforms != []
      then (if builtins.isNull gem then rest else gem)
      else assert assertMsg (fallback != null) "gemset: platforms.ruby.${name} missing"; fallback;

  getGem = platform: gem:
    let gems = importedGemset.platforms.${platform};
    in if gems ? ${gem} then gems.${gem} else null;
in {
  inherit (gemFiles) gemfile lockfile;
  gemset = platformGemset envPlatform;
}
