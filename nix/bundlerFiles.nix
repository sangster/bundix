{
}:

 # TODO: Can this be imported?
 # https://github.com/NixOS/nixpkgs/blob/48e4e2a1/pkgs/development/ruby-modules/bundled-common/functions.nix
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
}
