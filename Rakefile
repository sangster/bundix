# frozen_string_literal: true

require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new do |t|
  t.pattern = 'test/*.rb'
  t.warning = false
end

namespace :lint do
  RuboCop::RakeTask.new
end

task default: %i[test lint:rubocop]
