# frozen_string_literal: true

require_relative '../../test_helper'
require 'bundix/commandline'

class CommandLineTest < UnitTest
  def setup
    @cli = Bundix::CommandLine.new
    @cli.options = {
      project: 'test-project',
      ruby: 'test-ruby',
      gemfile: 'test-gemfile',
      lockfile: 'test-lockfile',
      gemset: 'test-gemset'
    }
  end

  def test_shell_nix
    assert_equal(<<~SHELLNIX, @cli.shell_nix_string)
      with (import <nixpkgs> {});
      let
        env = bundlerEnv {
          name = "test-project-bundler-env";
          inherit test-ruby;
          gemfile  = ./test-gemfile;
          lockfile = ./test-lockfile;
          gemset   = ./test-gemset;
        };
      in stdenv.mkDerivation {
        name = "test-project";
        buildInputs = [ env ];
      }
    SHELLNIX
  end
end
