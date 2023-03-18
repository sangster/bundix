{ defaultPlatform ? "ruby"
, ...
}:

let
  sysPlatforms = {
    aarch64-darwin = "arm64-darwin";
    aarch64-linux = "arm64-linux";
    x86_64-darwin = "x86_64-darwin";
    x86_64-linux = "x86_64-linux";
  };
in system:
  if sysPlatforms ? ${system}
  then sysPlatforms.${system}
  else defaultPlatform
