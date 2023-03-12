{ stdenv
, lib
, src
, pname
, version
, gems
, runtimeInputs ? []
, ...
}:
stdenv.mkDerivation {
  inherit gems pname src version;
  inherit (gems) ruby;
  phases = "installPhase";
  installPhase = ''
    mkdir -p $out/{bin,share/${pname}}
    cp -r $src/{bin,lib,template} $out/share/${pname}

    cat << EOF > "$out/bin/${pname}"
    #!/bin/sh -e
    export PATH="${lib.makeBinPath runtimeInputs}:$PATH"
    exec $gems/bin/bundle exec \
      $ruby/bin/ruby \
      $out/share/${pname}/bin/${pname} "\$@"
    EOF
    chmod +x "$out/bin/${pname}"
  '';
  meta = {
    inherit version;
    description = "Creates Nix packages from Gemfiles";
    longDescription = ''
      This is a tool that converts Gemfile.lock files to nix expressions.

      The output is then usable by the bundlerEnv derivation to list all the
      dependencies of a ruby package.
    '';
    homepage = "https://github.com/sangster/bundix";
    license = "MIT";
    maintainers = [ { name = "Jon Sangster"; email = "jon@ertt.ca";
                       github = "sangster"; githubId = 996850; } ];
    platforms = lib.platforms.all;
  };
}
