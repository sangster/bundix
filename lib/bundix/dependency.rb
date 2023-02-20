# frozen_string_literal: true

module Bundix
  class Dependency < Bundler::Dependency
    attr_reader :version

    def initialize(name, version, options = {}, &blk)
      super(name, version, options, &blk)
      @bundix_version = version
    end
  end
end
