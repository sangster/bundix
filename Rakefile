# frozen_string_literal: true

require 'rake/testtask'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

namespace :dev do
  desc 'Start a ruby REPL'
  task :console do
    require 'pry-byebug'
    require_relative './lib/bundix'
    Pry.start
  end

  desc 'Automatically execute tests when files are changed'
  task :guard do
    sh 'guard'
  end
end

namespace :docs do
  YARD::Rake::YardocTask.new(:generate)

  desc 'Serve YARD Documentation with web server'
  task(:serve) { YARD::CLI::Server.new.run }
end

namespace :test do
  RSpec::Core::RakeTask.new(:specs)
end

namespace :lint do
  RuboCop::RakeTask.new
end

desc 'Run all tests and linters'
task default: %i[test:specs lint:rubocop]
