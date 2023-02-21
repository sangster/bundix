# frozen_string_literal: true

require 'English'
require 'erb'
require 'optparse'
require 'pathname'
require 'tempfile'
require 'tmpdir'

module Bundix
  # Provides a command-line interface to {Converter}.
  class CommandLine
    attr_accessor :options

    def self.run
      new.run
    end

    def initialize
      @options = parse_options
    end

    def run
      parse_options
      handle_magic
      handle_lock
      handle_init
      save_gemset(build_gemset)
    end

    def shell_nix_context
      ShellNixContext.from_hash(options)
    end

    def shell_nix_string
      path = File.expand_path('../../template/shell-nix.erb', __dir__)
      tmpl = ERB.new(File.read(path))
      tmpl.result(shell_nix_context.bind)
    end

    private

    def parse_options
      op = CommandLineOptions.new
      op.parse!

      $VERBOSE = !op.options[:quiet]
      op.options
    end

    def handle_magic
      ENV['BUNDLE_GEMFILE'] = options[:gemfile]
      return unless options[:magic]

      ruby = options[:ruby]
      raise unless System.nix_bundle_lock(ruby, options[:lockfile])
      raise unless System.nix_bundle_pack(ruby, options[:bundle_pack_path])
    end

    def handle_init
      return unless options[:init]

      if File.file?('shell.nix')
        warn "won't override existing shell.nix but here is what it'd look like:"
        puts shell_nix_string
      else
        File.write('shell.nix', shell_nix_string)
      end
    end

    def handle_lock
      return unless options[:lock]

      lock = !File.file?(options[:lockfile])
      lock ||= File.mtime(options[:gemfile]) > File.mtime(options[:lockfile])
      return unless lock

      system_bundle_lock
    end

    def system_bundle_lock
      ENV.delete('BUNDLE_PATH')
      ENV.delete('BUNDLE_FROZEN')
      ENV.delete('BUNDLE_BIN_PATH')

      system('bundle', 'lock')
      raise 'bundle lock failed' unless $CHILD_STATUS.success?
    end

    def build_gemset
      Converter.new(options).convert
    end

    def save_gemset(gemset)
      tempfile = Tempfile.new('gemset.nix', encoding: 'UTF-8')
      tempfile.write(Nixer.serialize(gemset))
      tempfile.write("\n")
      tempfile.flush

      FileUtils.cp(tempfile.path, options[:gemset])
      FileUtils.chmod(0o644, options[:gemset])
    ensure
      tempfile.close!
      tempfile.unlink
    end
  end
end
