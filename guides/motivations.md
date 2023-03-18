# Motivations

This guide describes the reasoning behind Bundix and why it works how it does.

## Bundix 2 Motivations

See [Bundix v2.5.1](https://github.com/nix-community/bundix/tree/2.5.1).

> I'd usually just tell you to read the code yourself, but the big picture is
> that bundix tries to fetch a hash for each of your bundle dependencies and
> store them all together in a format that Nix can understand and is then used
> by `bundlerEnv`.
>
> I wrote this new version of bundix because I became frustrated with the poor
> performance of the old bundix, and wanted to save both time and bandwidth, as
> well as learn more about Nix.
>
> For each gem, it first tries to look for an existing gem in the bundler cache
> (usually generated via `bundle package`), and if that fails it goes through
> each remote and tries to fetch the gem from there. If the remote happens to be
> [rubygems.org](http://rubygems.org/) we ask the API first for a hash of the
> gem, and then ask the Nix store whether we have this version already. Only if
> that also fails do we download the gem.
>
> As an added bonus I also implemented parsing the `gemset.nix` if it already
> exists, and get hashes from there directly, that way updating an existing
> `gemset.nix` only takes a few seconds.
>
> The output from bundix should be as stable as possible, to make auditing diffs
> easier, that's why I also implemented a pretty printer for the `gemset.nix`.
>
> I hope you enjoy using bundix as much as I do, and if you don't, let me know.

## Bundix 3 Motivations

Bundix 2 is an incredible tool, but after two years of daily use, I've stumbled
across a few areas where it needs improvement. Notably:

 - When a `Gemfile.lock` includes multiple platforms.
 - When a `Gemfile` specifies gem groups.
 - Bundler integration

 Consider how Bundix 2 handles the example `Gemfile` from the [Getting
 Stated](./getting-started.md) guide:

```ruby
source 'https://rubygems.org'
gem 'nokogiri', '1.14.2'
gem 'test-unit', '3.5.7', group: :development
```

In that guide, we also configured our bundle to include both the `ruby` and
`x86_64-linux` platforms, so its `Gemfile.lock` includes these `GEM` and
`PLATFORM` sections:

```
GEM
  remote: https://rubygems.org/
  specs:
    mini_portile2 (2.8.1)
    nokogiri (1.14.2)
      mini_portile2 (~> 2.8.0)
      racc (~> 1.4)
    nokogiri (1.14.2-x86_64-linux)
      racc (~> 1.4)
    power_assert (2.0.3)
    racc (1.6.2)
    test-unit (3.5.7)
      power_assert

PLATFORMS
  ruby
  x86_64-linux
```

If we run these files through Bundix 2, it generates this `gemset.nix`:

```nix
{
  mini_portile2 = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1af4yarhbbx62f7qsmgg5fynrik0s36wjy3difkawy536xg343mp";
      type = "gem";
    };
    version = "2.8.1";
  };
  nokogiri = {
    dependencies = ["mini_portile2" "racc"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1djq4rp4m967mn6sxmiw75vz24gfp0w602xv22kk1x3cmi5afrf7";
      type = "gem";
    };
    version = "1.14.2";
  };
  power_assert = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1y2c5mvkq7zc5vh4ijs1wc9hc0yn4mwsbrjch34jf11pcz116pnd";
      type = "gem";
    };
    version = "2.0.3";
  };
  racc = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09jgz6r0f7v84a7jz9an85q8vvmp743dqcsdm3z9c8rqcqv6pljq";
      type = "gem";
    };
    version = "1.6.2";
  };
  test-unit = {
    dependencies = ["power_assert"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1rdhpdi8mlk7jwv9pxz3mhchpd5q93jxzijqhw334w5yv1ajl5hf";
      type = "gem";
    };
    version = "3.5.7";
  };
}
```

### Platform issues

The most pressing issue with this generated `gemset.nix` is that only one
version of `nokogiri` made it in. In this example it was the `ruby` version,
with the `x86_64-linux` nowhere to be found. If you attempt to build this nix
package on an `x86_64-linux` machine, Bundler will raise an error like:

```
Could not find nokogiri-1.14.2-x86_64-linux in locally installed gems (Bundler::GemNotFound)
```

The `nokogiri-1.14.2` pure-ruby gem *is* available, but Bundler sees that
`nokogiri (1.14.2-x86_64-linux)` is in the `Gemfile.lock` and always wants to use
the most-specific version for the current platform.

### Grouping issues

The second problem with this `gemset.nix` is how transitive dependencies are
grouped. In the above `Gemset` we added `test-unit` to the `development` group.
In the generated `gemset.nix` it is correctly in that group; however, its
transitive dependency, `power_assert`, found its way into the `default` group.
This means that `power_assert` (but not `test-unit`, the gem that uses it) will
always be erroneously included in nix package.

The reason for this error is because `power_assert` is in the `default` group...
of the `test-unit` gem. Bundix 2 doesn't realise that a `default` dependency of
one of our project's `development` dependencies should also be rendered as a
`development` dependency.

### Bundler integration

This issue is a bit more vague, but there is a certain chicken-and-egg problem I
run into occasionally, when a colleague has updated our `Gemfile`, but didn't
(or incorrectly) update the `Gemfile.lock`. Especially for projects that use
git-sources.

Bundix 2 uses the `Gemfile.lock` to generate the `gemset.nix` file. If it sees
that the `Gemfile.lock` needs to be updated, it will ask `Bundler` to update it.
However, Bundler may complain that you need to run `bundle install` to update
the `Gemfile.lock` (as some remote depenendcies are unmet). However, `bundle
install` will want to build all the gem dependencies. This will probably fail,
since we're on a nix system, and use Bundix to build them. But... Bundix needs
an updated `gemset.nix` to build the correct ones. And so on.

Bundix 3 avoids this issue by removing Bundler from the equation and updating
the `Gemfile.lock` itself.
