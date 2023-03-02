{
  pkgs ? (import <nixpkgs> {}),
  ruby ? pkgs.ruby_2_7,
  bundler ? (pkgs.bundler.override { inherit ruby; }),
  nix ? pkgs.nix,
  nix-prefetch-git ? pkgs.nix-prefetch-git,
}:
pkgs.stdenv.mkDerivation rec {
  version = "3.0.0-alpha";
  name = "bundix";
  src = ./.;
  phases = "installPhase";
  installPhase = ''
    mkdir -p $out
    makeWrapper $src/bin/bundix $out/bin/bundix \
      --prefix PATH : "${nix.out}/bin" \
      --prefix PATH : "${nix-prefetch-git.out}/bin" \
      --prefix PATH : "${bundler.out}/bin" \
      --set GEM_PATH "${bundler}/${bundler.ruby.gemPath}"
  '';

  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildInputs = [ ruby bundler ];

  meta = {
    inherit version;
    description = "Creates Nix packages from Gemfiles";
    longDescription = ''
      This is a tool that converts Gemfile.lock files to nix expressions.

      The output is then usable by the bundlerEnv derivation to list all the
      dependencies of a ruby package.
    '';
    homepage = "https://github.com/nix-community/bundix";
    license = "MIT";
    maintainers = with pkgs.lib.maintainers; [ manveru zimbatm ];
    platforms = pkgs.lib.platforms.all;
  };
}
