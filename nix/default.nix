{ callPackage }:

let
  extractBundixVersion = callPackage ./extractBundixVersion.nix {};
  platformGemset = callPackage ./platformGemset.nix {};
in {
  inherit extractBundixVersion platformGemset;
}
