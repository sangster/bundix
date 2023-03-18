{ callPackage }:

{
  bundlerFiles = callPackage ./bundlerFiles.nix {};
  extractBundixVersion = callPackage ./extractBundixVersion.nix {};
  toBundlerEnvArgs = callPackage ./toBundlerEnvArgs.nix {};
}
