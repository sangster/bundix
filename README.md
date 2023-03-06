# About

Bundix makes it easy to package your [Bundler](http://bundler.io/)-enabled Ruby
applications with the [Nix](http://nixos.org/nix/) package manager.

## Installation

Installing from this repo:

    nix-env -iA bundix

Please note that in order to actually use this gem you must have Nix installed.

## Basic Usage

I recommend first reading the
[nixpkgs manual entry for Ruby](http://nixos.org/nixpkgs/manual/#sec-language-ruby)
as this README might become outdated, it's a short read right now, so you won't
regret it.

1. Making a gemset.nix

   Change to your project's directory and run this:

       bundix -l

   This will generate a `gemset.nix` file that you then can use in your
   `bundlerEnv` expression like this:

2. Using `nix-shell`

   To try your package in `nix-shell`, create a `default.nix` like this:

   ```nix
   with (import <nixpkgs> {});
   let
     gems = bundlerEnv {
       name = "your-package";
       inherit ruby;
       gemdir = ./.;
     };
   in stdenv.mkDerivation {
     name = "your-package";
     buildInputs = [gems ruby];
   }
   ```

   and then simply run `nix-shell`.

3. Proper packages

   To make a package for nixpkgs, you can try something like this:

   ```nix
   { stdenv, bundlerEnv, ruby }:
   let
     gems = bundlerEnv {
       name = "your-package";
       inherit ruby;
       gemdir  = ./.;
     };
   in stdenv.mkDerivation {
     name = "your-package";
     src = ./.;
     buildInputs = [gems ruby];
     installPhase = ''
       mkdir -p $out
       cp -r $src $out
     '';
   }
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
