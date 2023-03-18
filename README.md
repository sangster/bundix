# About
Bundix makes it easy to package your [Bundler](http://bundler.io/)-enabled Ruby
applications with the [Nix](https://nixos.org/download.html) package manager.

# Basic Usage

**Note**: See [Getting Started](./guides/getting-started.md) for a more detailed
description of setting up a new ruby project.

> Please note that in order to actually use this gem you must have Nix installed.
>
> I recommend first reading the [nixpkgs manual entry for
> Ruby](http://nixos.org/nixpkgs/manual/#sec-language-ruby) as this README might
> become outdated, it's a short read right now, so you won't regret it.

To use Bundix, all your project needs is a `Gemfile` describing your project's
ruby dependencies. If you already have a `Gemfile.lock`, Bundix will use it, but
it will generate one if you don't.

``` sh
$ nix run github:sangster/bundix
$ nix run nixpkgs#git -- add gemset.nix
```

## Adding Bundix to your `flake.nix`

To integrate Bundix into your Nix package, you'll need to make 3 changes:

### 1. Import Bundix's overlay

For example, if you have a `import nixpkgs` line in your flake, add a `overlays
= [ ...];` attribute to it. For example:

``` nix
{
  inputs.bundix.url = github:sangster/bundix;

  outputs = { bundix, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [bundix.overlays.default];
      };
    in { ... }
}
```

### 2. Create the gem bundle with Bundix

Now we use the `pkgs.bundixEnv` nix function to convert your project's
`gemset.nix` into a nix derivation that will be used as a runtime dependency for
your own ruby package. Here is an example usage:

``` nix
gems = pkgs.bundixEnv {
  name = "bundix-project-gems";
  ruby = pkgs.ruby;
  gemdir = ./.;
  platform = "x86_64-linux";
};
```

`bundixEnv` accepts the same attribute arguments as
[bundlerEnv](https://github.com/NixOS/nixpkgs/blob/48e4e2a1/pkgs/development/ruby-modules/bundler-env/default.nix),
with the addition of two:

 - `platform`: Specifies the gem platform we want to build this package for.
 - `system`: As an alternative to `platform`, you can provide your nix `system`
   and `bundixEnv` will attempt to figure out the correct `platform` from that.

### 3. Use the gem bundle in your app

Finally, you need to integrate your new gem bundle into your package. An easy
method is to use its `wrappedRuby` package as the `ruby` used to execute your
ruby code.

``` nix
pkgs.stdenv.mkDerivation {
  phases = "installPhase";
  installPhase = ''
    mkdir -p $out/bin
    cat << EOF > "$out/bin/my-app"
    #!/bin/sh
    exec ${gems.wrappedRuby}/bin/ruby ${./my-ruby-script.rb}
    EOF
    chmod +x "$out/bin/my-app"
  '';
};
```

### Generate an example `flake.nix`

If your project doesn't have a +flake.nix+ yet, Bundix can make an example one
for you:

``` sh
$ nix run github:sangster/bundix -- --init
```

## Command-line Flags

```
$ nix run github:sangster/bundix -- --help
Usage: bundix [options]
    -q, --quiet                      only output errors

File options:
        --gemfile=PATH               path to the existing Gemfile (default: ./Gemfile)
        --lockfile=PATH              path to the Gemfile.lock (default: ./Gemfile.lock)

Output options:
        --gemset=PATH                destination path of the gemset.nix (default: ./gemset.nix)
    -g, --groups=GROUPS              bundler groups to include in the gemset.nix (default: all groups)
        --bundler-env[=PLATFORM]     export a nixpkgs#bundlerEnv compatiblegemset (default: ruby)
        --skip-gemset                do not generate gemset

Bundler options:
    -l, --lock                       lock the gemfile gems into the lockfile
    -u, --update[=GEMS]              update the lockfile with new versions of the specified gems, or each one, if none given (implies --lock)
    -a, --add-platforms=PLATFORMS    add platforms to the lockfile (implies --lock)
    -r, --remove-platforms=PLATFORMS remove platforms from the lockfile (implies --lock)
    -p, --platforms=PLATFORMS        replace all platforms in the lockfile (implies --lock)
    -c, --bundle-cache[=DIR]         package .gem files into directory (default: ./vendor/bundle)
        --ignore-bundler-configs     ignores Bundler config files

flake.nix options:
    -i, --init[=RUBY_DERIVATION]     initialize a new flake.nix for 'nix develop' (won't overwrite old ones)
    -t, --init-template=TEMPLATE     the flake.nix template to use. may be 'default', 'flake-utils', or a filename (default: default)
    -n, --project-name=NAME          project name to use with --init (default: bundix)

Environment options:
    -v, --version                    show the version of bundix
        --env                        show the environment in Bundix
        --platform                   show the gem platform of this host
```

## How & Why

I'd usually just tell you to read the code yourself, but the big picture is
that bundix tries to fetch a hash for each of your bundle dependencies and
store them all together in a format that Nix can understand and is then used by
`bundlerEnv`.

I wrote this new version of bundix because I became frustrated with the poor
performance of the old bundix, and wanted to save both time and bandwidth, as
well as learn more about Nix.

For each gem, it first tries to look for an existing gem in the bundler cache
(usually generated via `bundle package`), and if that fails it goes through
each remote and tries to fetch the gem from there. If the remote happens to be
[rubygems.org](http://rubygems.org/) we ask the API first for a hash of the
gem, and then ask the Nix store whether we have this version already. Only if
that also fails do we download the gem.

As an added bonus I also implemented parsing the `gemset.nix` if it already
exists, and get hashes from there directly, that way updating an existing
`gemset.nix` only takes a few seconds.

The output from bundix should be as stable as possible, to make auditing diffs
easier, that's why I also implemented a pretty printer for the `gemset.nix`.

I hope you enjoy using bundix as much as I do, and if you don't, let me know.

## Development

If you wish to further develop this project, [`Rakefile`](./Rakefile), provides
some utilities which may help you. Furthermore, running `nix develop` will start
a new shell where `rake`, and other development dependencies are available. Some
example `rake` commands (via `nix develop` in these examples):

``` sh
$ nix develop -c rake -T           # List available rake commands
$ nix develop -c rake              # Default rake command: all tests and linters
$ nix develop -c rake dev:console  # Open a ruby REPL shell
$ nix develop -c rake dev:guard    # Begin automated test-runner
```

### Building

As a nix package, this gem can be built with `nix build`. The derivation will be
built in the nix store, and a symlink to its directory will be created at
`./result`.

As a convenience, you can build *and* run Bundix with `nix run .#`. Any
command-line arguments must be preceeded with `--`; for example:
`nix run .# -- --help`.

## Closing words

For any questions or suggestions, please file an issue on Github or ask in
`#nixos` on [Freenode](http://freenode.net/).

Big thanks go out to
[Charles Strahan](http://www.cstrahan.com/) for his awesome work bringing Ruby to Nix,
[zimbatm](https://zimbatm.com/) for being a good rubber duck and tester, and
[Alexander Flatter](https://github.com/aflatter) for the original bundix. I
couldn't have done this without you guys.
