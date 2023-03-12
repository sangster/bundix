# frozen_string_literal: true

module Bundix
  # A version of {Bundler::Settings} that allows greaters control over settings.
  class BundlerSettings < Bundler::Settings
    # @param ignore_config [Bool,nil] Whether to ignore settings from Bundler
    #   config files. +nil+ to use the +BUNDLE_IGNORE_CONFIG+ environment
    #   variable.
    def initialize(*args, ignore_config: nil)
      @ignore_config = ignore_config

      super(*args)
    end

    def ignore_config?
      @ignore_config.nil? ? super : @ignore_config
    end
  end
end
