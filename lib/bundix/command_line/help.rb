# frozen_string_literal: true

require 'optparse'

module Bundix
  class CommandLine
    # Provides documentation for the +--help+ command-line argument.
    module Help
      class << self
        def default(key)
          "(default: #{DEFAULT_OPTIONS[key]})"
        end

        def template_list
          FLAKE_NIX_TEMPLATES.keys.map { |str| "'#{str}'" }.join(', ')
        end
      end

      FLAGS = {
        '--quiet' => 'only output errors',

        # Input options
        '--gemfile=PATH' => "path to the existing Gemfile #{default :gemfile}",
        '--lockfile=PATH' => "path to the Gemfile.lock #{default :lockfile}",

        # Output options
        '--gemset=PATH' =>
          "destination path of the gemset.nix #{default :gemset}",
        '--bundler-env[=PLATFORM]' => 'export a nixpkgs#bundlerEnv compatible' \
                                      "gemset #{default :ruby_platform}",
        '--skip-gemset' => 'do not generate gemset',

        # Bundler options
        '--lock' => 'lock the gemfile gems into the lockfile',
        '--update[=GEMS]' =>
          'update the lockfile with new versions of the specified gems, or ' \
          'each one, if none given (implies --lock)',
        '--bundle-cache[=DIR]' =>
          "package .gem files into directory #{default :bundle_cache_path}",
        '--ignore-bundler-configs' => 'ignores Bundler config files',

        # flake.nix options
        '--init[=RUBY_DERIVATION]' => "initialize a new flake.nix for 'nix " \
                                      "develop' (won't overwrite old ones)",
        '--init-template=TEMPLATE' =>
          "the flake.nix template to use. may be #{template_list}, or a " \
          'filename (default: default)',
        '--init-project=NAME' =>
          "project name to use with --init #{default :project}",

        # Environment options
        '--version' => 'show the version of bundix',
        '--env' => 'show the environment in Bundix',
        '--platform' => 'show the gem platform of this host'
      }.freeze

      def on(*args, &blk)
        super(*args.push(flag_help(args)), &blk)
      end

      private

      def flag_help(args)
        FLAGS.fetch(args.find { _1.start_with?('--') })
      end
    end
  end
end
