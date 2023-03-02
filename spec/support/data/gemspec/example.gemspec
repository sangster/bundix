# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'example'
  s.version = '0.1.0'
  s.summary = 'example gemspec'
  s.authors = ['example']
  s.required_ruby_version = '>= 2.7.0'
  s.metadata['rubygems_mfa_required'] = 'true'

  s.add_dependency 'zeitwerk', '~> 2.6'
  s.add_development_dependency 'rubocop', '~> 1.45'
end
