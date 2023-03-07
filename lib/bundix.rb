# frozen_string_literal: true

require 'bundler'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup

module Bundix
  CACHE_DIR = File.join(ENV['XDG_CACHE_HOME'] || "#{Dir.home}/.cache", 'bundix').freeze
  SHA256_32 = /^[a-z0-9]{52}$/.freeze
  SHELL_NIX_TEMPLATE = Pathname('./template/shell.nix.erb').freeze
end
