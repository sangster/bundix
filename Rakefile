# frozen_string_literal: true

require 'rake/testtask'
require 'rubocop/rake_task'

desc 'Start a ruby REPL'
task :console do
  require 'pry-byebug'
  require_relative './lib/bundix'
  Pry.start
end

Rake::TestTask.new do |t|
  t.pattern = 'test/**/*_test.rb'
  t.warning = false
end

namespace :lint do
  RuboCop::RakeTask.new
end

task default: %i[test lint:rubocop]
