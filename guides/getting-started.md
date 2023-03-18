# Getting Started

This guide will walk you through setting up an example ruby project and
packaging it with a [nix flake](https://nixos.wiki/wiki/Flakes). To help you
understand what Bundix is doing, and to be better able to configure your
projects how you want, this document will go through each step in great detail.
If that doesn't interest you, the [README](../README.md) has introduction that
can get you started much more quickly.

> Please note that in order to actually use this gem you must have Nix installed.
>
> Consider first reading the [nixpkgs manual entry for
> Ruby](http://nixos.org/nixpkgs/manual/#sec-language-ruby). Bundix makes much
> of this easier, but it's still handy to know what Nix is doing under the hood.

## Creating a Ruby Project (optional)

If you're writing a nix package for an existing ruby project, you can skip this
step. But if you just want to try out Bundix with an example project, all you
need to start is a `git` repo[^git] with a `Gemfile` that includes all your
[favourite gems](https://rubygems.org/):

[^git]: If you prefer not to use `git`, Nix supports other version control
        systems.

```sh
$ nix run nixpkgs#git -- init bundix-project
Initialized empty Git repository in ~/bundix-project/.git/
$ cd ./bundix-project/
$ cat <<RUBY > ./Gemfile
source 'https://rubygems.org'
gem 'nokogiri', '1.14.2'
gem 'minitest', '5.18.0', group: :development
RUBY
```

 - [Nokogiri](https://nokogiri.org/) will allow your hypothetical project to
   easily work with XML and HTML.
 - [Minitest](https://github.com/minitest/minitest) provides an API for writing
   unit tests. Unlike Nokogiri, Minitest is a "development dependency." You need
   it to help you write your application, but it won't necessarily be needed
   by your app at runtime. For this reason, we've added it to your Gemfile's
   `development` group.

### Generating your project's nix files

While typical ruby projects include many source files, Bundix only needs your
`Gemfile` to be present.

```sh
$ nix run github:sangster/bundix -- --init
Fetching gem metadata from https://rubygems.org/.......
Resolving dependencies...
Writing lockfile to ~/bundix-project/Gemfile.lock
```

Bundix will create 3 files:

 - `Gemfile.lock`
 - `gemset.nix`
 - `flake.nix`

### Gemfile.lock

Since the example project didn't have a `Gemfile.lock`, Bundix will have created
one similar to this:

```
GEM
  remote: https://rubygems.org/
  specs:
    minitest (5.18.0)
    nokogiri (1.14.2-x86_64-linux)
      racc (~> 1.4)
    racc (1.6.2)

PLATFORMS
  x86_64-linux

DEPENDENCIES
  minitest (= 5.18.0)
  nokogiri (= 1.14.2)

BUNDLED WITH
   2.4.6
```

Typically you won't ever edit, or even look at, this file, but here's a quick
summary of its major sections:

#### GEM

 The `GEM` section summarises all the gems that need to be downloaded from
`rubygems.org` to build this project. Even though our `Gemfile`only listed 2
gems, this section includes 3. `racc` was pulled in as a transitive dependency
of `nokogiri`.

#### PLATFORMS

The `PLATFORMS` section lists the [gem
platforms](https://guides.rubygems.org/what-is-a-gem/) your project intends to
support. By default, when creating a new `Gemfile.lock`, the platform of your
local machine is used.[^platform]

[^platform]: I used a 64-bit linux machine in this example. Your `Gemfile.lock`
             may have something different here.

You probably noticed that the `nokogiri` entry under `GEMS` lists the version as
`1.14.2-x86_64-linux`, even though the `Gemfile` specified that version `1.14.2`
is needed. This is because `nokogiri` provides a special version of this gem
specifically for this `Gemfile.lock`'s platform[^nokogiri]. `Gemfile.lock`
*only* lists `x86_64-linux` as a supported platform, so it's acceptable to use a
`x86_64-linux`-only version of `nokogiri`.

[^nokogiri]: Nokogiri provides versions for other platforms too. You can see a
             list on their [RubyGems page](https://rubygems.org/gems/nokogiri/versions).

If you're building a nix derivation that you want to run on all ruby platforms,
you can use the special, `ruby` platform. This platform indicates that your code
doesn't contain any platform-specific code and can hypothetically run on any
platform.

You can add the `ruby` platform to your `Gemfile.lock` with the
`--add-platforms=` flag:

```sh
$ nix run github:sangster/bundix -- --add-platforms=ruby
Fetching gem metadata from https://rubygems.org/.......
Resolving dependencies...
Writing lockfile to /tmp/bundix-project/Gemfile.lock
```

By examining the updated `Gemfile.lock`, you'll see that the `PLATFORMS` section
has a second entry, and a few more gems added to the `GEMS` section:

```
GEM
  remote: https://rubygems.org/
  specs:
    mini_portile2 (2.8.1)
    minitest (5.18.0)
    nokogiri (1.14.2)
      mini_portile2 (~> 2.8.0)
      racc (~> 1.4)
    nokogiri (1.14.2-x86_64-linux)
      racc (~> 1.4)
    racc (1.6.2)

PLATFORMS
  ruby
  x86_64-linux
```

There are now two `nokogiri` entries: one for the `x86_64-linux` platform and a
generic ruby one (with no platform suffix) for every other platform. Take note
that the pure-ruby implementation of `nokogiri` has an extra transitive
dependency: `mini_portile2`.

#### DEPENDENCIES

The `DEPENDENCIES` section reiterates the gems listed in your `Gemfile`. The gem
entries in the `GEM` section are meant to fulfill the requirements listed here.

### gemset.nix

Your project's `gemset.nix` file is almost the same as its `Gemfile.lock`. It's
purpose is to catalogue all your needed gems, along with the groups and
platforms they support. Unlike the `Gemfile.lock`, this file also includes the
[SHA-256 hash](https://en.wikipedia.org/wiki/SHA-2#Applications) of each gem.

Recall that the purpose of the nix package manager is to provide reproducable
builds. To fulfill that guarantee, we need to record these hashes in advance, so
the built-gems can be verified at build time. Bundler itself isn't concerned
with reproducable builds and the `Gemfile`/`Gemfile.lock` aren't enough on their
own, so the `gemset.nix` file is necessary.

The `gemset.nix` generated in your project should look like this[^platform2]:

[^platform2]: Again, your file will certainly look different if your local
              platform is something other than `x86_64-linux`.

``` nix
{
  dependencies = ["minitest" "nokogiri"];
  platforms = {
    ruby = {
      mini_portile2 = {
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1af4yarhbbx62f7qsmgg5fynrik0s36wjy3difkawy536xg343mp";
          type = "gem";
        };
        version = "2.8.1";
      };
      minitest = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0ic7i5z88zcaqnpzprf7saimq2f6sad57g5mkkqsrqrcd6h3mx06";
          type = "gem";
        };
        version = "5.18.0";
      };
      nokogiri = {
        dependencies = ["mini_portile2" "racc"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1djq4rp4m967mn6sxmiw75vz24gfp0w602xv22kk1x3cmi5afrf7";
          type = "gem";
        };
        version = "1.14.2";
      };
      racc = {
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "09jgz6r0f7v84a7jz9an85q8vvmp743dqcsdm3z9c8rqcqv6pljq";
          type = "gem";
        };
        version = "1.6.2";
      };
    };
    x86_64-linux = {
      nokogiri = {
        dependencies = ["racc"];
        platforms = [{ engine = "ruby"; }];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0xp427axb5h5rbdgmcviqdc6wk62q3qpbmw23x06xb6xyghhar5w";
          type = "gem";
        };
        version = "1.14.2-x86_64-linux";
      };
    };
  };
}
```

Here's an overview of the sections in this `gemset.nix`:

```
dependencies
platforms
  ruby
    mini_portile2
    minitest
    nokogiri
    racc
  x86_64-linux
    nokogiri
```

 - `dependencies` is the same as your `Gemset.lock` file's `DEPENDENCIES`
   section. It lists all the top-level requirements you listed in your
   `Gemfile`.
 - `platforms` lists each of your gem dependencies, divided up by platform. At
   build time, Bundix will choose the apropriate ones for the target system.

The section for each of the listed gems have mostly the same attributes:

 - `dependencies` (optional): Transitive dependencies of that gem. if any
 - `groups` (optional): What group, if any, the gem belongs to in the `Gemfile`.
 - `platforms` (optional): Despite the name `platforms`, this attribute
   describes the type of
   [ruby engine](https://bundler.io/v1.12/man/gemfile.5.html#ENGINE-engine-)
   this gem requires. This attribute will be absent if the gem is a generic
   `ruby` gem that can run on any engine.
 - `source`: Describes where nix can download the gem. See below for more
   details.
 - `version`: The exact version number of the gem.

#### Gem sources

Bundler allows you to add gems to your `Gemfile` from 3 kinds of sources, and
Bundix supports them all:

 - [RubyGems server](https://guides.rubygems.org/publishing). This will often be
   `rubygems.org`, but it doesn't have to be. You can use GitHub's RubyGems
   server or any other that is compliant with the
   [RubyGems API](https://guides.rubygems.org/rubygems-org-api/).
 - [git repository](https://bundler.io/guides/git.html)
 - A directory on the local filesystem. Please note that if you reference a path
   outside of your project's git repo, Nix may require that you use the
   `--impure` flag[^impure].

[^impure]: For example, `nix build --impure` or `nix run --impure`.

### flake.nix

Because we ran Bundix with the `--init` flag, it created an example `flake.nix`
file for your project. Here's a truncated version that highlights the important
parts:

``` nix
{
  inputs.bundix.url = github:sangster/bundix;

  outputs = { self, nixpkgs, bundix }:
    let
      pname = "bundix-project";
      system = "x86_64-linux";
      version = "0.0.1";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [bundix.overlays.default];
      };

      gems = pkgs.bundixEnv {
        inherit system;
        name = "${pname}-${version}-gems";
        groups = ["default"];
        ruby = pkgs.ruby;
        gemdir = ./.;
      };
    in {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        inherit gems pname version;
        ruby = gems.wrappedRuby;
        phases = "installPhase";
        installPhase = ''
          mkdir -p $out/bin
          cat << EOF > "$out/bin/${pname}"
          #!/bin/sh
          exec $ruby/bin/ruby << RUBY
          require 'bundler'
          Bundler.setup(:default)
          puts "Loaded gems:"
          Gem.loaded_specs.each_key { |gem| puts " - #{gem}" }
          RUBY
          EOF
          chmod +x "$out/bin/${pname}"
        '';
      };
}
```

#### Importing the Bundix overlay

``` nix
pkgs = import nixpkgs {
  inherit system;
  overlays = [bundix.overlays.default];
};
```

The Bundix overlay gives your flake access to the `bundixEnv` function that will
build your project's rubygems. Alternatively, if you don't want want to use an
overlay, you can reference this function with
`bundix.packages.${system}.bundixEnv`.

#### Building the gems

Now we use the `pkgs.bundixEnv` nix function to convert your project's
`gemset.nix` into a nix derivation that provides all the gems to your own ruby
package.

``` nix
gems = pkgs.bundixEnv {
  inherit system;
  name = "${pname}-${version}-gems";
  groups = ["default"];
  ruby = pkgs.ruby;
  gemdir = ./.;
};
```

`bundixEnv` accepts the same attribute arguments as
[bundlerEnv](https://github.com/NixOS/nixpkgs/blob/48e4e2a1/pkgs/development/ruby-modules/bundler-env/default.nix),
with the addition of two:

 - `platform`: Specifies the gem platform we want to build this package for.
 - `system`: As an alternative to `platform`, you can provide your nix `system`
   and `bundixEnv` will attempt to figure out the correct `platform` from that.

In this example, we've also set `groups = ["default"]`. Our `Gemfile` included
`minitest` in its `development` group. We don't need to include development
dependencies in our package, so this instructs Bundix to only build gems from
the default group (`nokogiri`). If `groups` is unspecified, every gem will be
included.


#### An example program

For demonstration purposes, the example `flake.nix` includes a simple sample
application. Here's the nix portion:

```nix
packages.${system}.default = pkgs.stdenv.mkDerivation {
  inherit gems pname version;
  ruby = gems.wrappedRuby;
  phases = "installPhase";
  installPhase = ''
    mkdir -p $out/bin
    cat << EOF > "$out/bin/${pname}"
    #!/bin/sh
    exec $ruby/bin/ruby <<< "# ... ruby code here ..."
    chmod +x "$out/bin/${pname}"
  '';
};
```

This package builds a single shell script (`$out/bin/bundix-project` in our
example) that runs `$ruby/bin/ruby` with a simple ruby script (shown below).
This simple shell script has access to our gem dependencies because the `$ruby`
being used by this script comes from `gems.wrappedRuby`. It's preconfigured to
point Bundler to the right nix paths.

Alternatively, if you prefer to use [bundle
exec](https://bundler.io/v2.4/man/bundle-exec.1.html), you can do so with
`$gems/bin/bundle exec COMMAND`.[^alternatively]

[^alternatively]: Or you can add them to your app's `$PATH`. Nix is provides a
                  lot of options for writing your package.

##### An example ruby script

The generated example script just proves that the bundle works by loading your
gems and printing their names:

```ruby
require 'bundler'
Bundler.setup(:default)

puts "Loaded gems:"
Gem.loaded_specs.each_key { |gem| puts " - #{gem}" }
```

It's important to note that, in this example, we are loading the gems with
`Bundler.setup(:default)`. Recall that we explicitly built our package to only
include runtime dependencies, and not development dependencies. If you try load
the dev-dependencies (with `Bundler.setup(:development)`) or *all* the
dependencies (with `Bundler.setup`), you'll get an error like:

```
Could not find minitest-5.18.0 in locally installed gems (Bundler::GemNotFound)
```
