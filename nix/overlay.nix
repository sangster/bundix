{ pname
, extraConfigPaths
, src
, versionRubyFile
}:
final: prev:
let
  inherit pname;
  lib = final.callPackage ./. {};

  version = lib.extractBundixVersion versionRubyFile;

  gems = with final; bundlerEnv {
    inherit extraConfigPaths ruby;
    name = "${pname}-${version}-bundler-env";
    gemdir = src;
  };

  package = final.callPackage ./derivation.nix {
    inherit gems pname src version;
    runtimeInputs = with final; [
      git
      nix
      nix-prefetch-git
    ];
  };

in {
  bundix = package;
  bundixEnv = args: final.bundlerEnv (args // lib.platformGemset args);
}
