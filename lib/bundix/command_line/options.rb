# frozen_string_literal: true

require 'optparse'

module Bundix
  class CommandLine
    # Parses command-line options.
    class Options < OptionParser
      include Help

      attr_accessor :options

      def initialize
        @options = DEFAULT_OPTIONS.dup
        super
        make_options
      end

      protected

      def make_options
        logging_options
        file_options
        bundler_options
        init_options
        environment_options
      end

      def logging_options
        on('-q', '--quiet') { options[:quiet] = true }
      end

      def file_options # rubocop:disable Metrics/AbcSize
        separator("\nFile options:")

        on('--gemfile=PATH') { options[:gemfile] = path(_1) }
        on('--lockfile=PATH') { options[:lockfile] = path(_1) }
        on('--gemset=PATH') { options[:gemset] = path(_1) }
        on('-g', '--groups=GROUPS', Array) { options[:groups] = _1 }
        on '--bundler-env[=PLATFORM]' do |platform|
          options[:bundler_env_format] = platform || options[:ruby_platform]
        end
        on('--skip-gemset') { options[:skip_gemset] = true }
      end

      def bundler_options # rubocop:disable Metrics/AbcSize
        separator("\nBundler options:")

        on('-l', '--lock') { options[:lock] = true }
        on('-u', '--update[=GEMS]', Array) { options[:update] = _1 || true }
        on('-a', '--add-platforms=PLATFORMS', Array) { options[:add_platforms] = _1 }
        on('-r', '--remove-platforms=PLATFORMS', Array) { options[:remove_platforms] = _1 }
        on('-p', '--platforms=PLATFORMS', Array) { options[:set_platforms] = _1 }
        on '-c', '--bundle-cache[=DIR]' do |dir|
          options[:cache] = path(dir, default: :bundle_cache_path)
        end
        on('--ignore-bundler-configs') { options[:ignore_config] = true }
      end

      def init_options
        separator("\nflake.nix options:")

        on '-i', '--init[=RUBY_DERIVATION]' do |ruby|
          options[:init] = ruby || options[:ruby_derivation]
        end
        on '-t', '--init-template=TEMPLATE' do |template|
          options[:init_template] = parse_template(template)
        end
        on('-n', '--project-name=NAME') { options[:project] = _1 }
      end

      def environment_options
        separator("\nEnvironment options:")

        on('-v', '--version') { puts VERSION && exit }
        on('--env') { system('env') && exit }
        on('--platform') { puts LOCAL_PLATFORM && exit }
      end

      private

      def path(str, default: nil)
        Pathname(str || options[default]).expand_path
      end

      def parse_template(template)
        if FLAKE_NIX_TEMPLATES.key?(template)
          FLAKE_NIX_TEMPLATES[template]
        elsif (user_template = path(template)).readable?
          user_template
        else
          raise OptionParser::InvalidArgument, "--init-template=#{template}"
        end
      end
    end
  end
end
