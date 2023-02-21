# frozen_string_literal: true

module Bundix
  # Executes shell commands.
  class Shell
    def self.sh(*args, &block)
      out, status = Open3.capture2(*args)
      unless block_given? ? block.call(status, out) : status.success?
        puts "$ #{args.join(' ')}" if $VERBOSE
        puts out if $VERBOSE
        raise "command execution failed: #{status}"
      end
      out
    end
  end
end
