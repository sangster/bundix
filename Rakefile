# frozen_string_literal: true

require 'rake/testtask'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

desc 'Start a ruby REPL'
task :console do
  require 'pry-byebug'
  require_relative './lib/bundix'
  Pry.start
end

RSpec::Core::RakeTask.new(:spec)

namespace :lint do
  RuboCop::RakeTask.new
end

task default: %i[spec lint:rubocop]
