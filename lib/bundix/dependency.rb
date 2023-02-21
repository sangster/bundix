# frozen_string_literal: true

module Bundix
  # A version of {Bundler::Dependency} that exposes its {#version}.
  class Dependency < Bundler::Dependency
    attr_reader :version
  end
end
