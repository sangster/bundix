# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'example'
  s.required_ruby_version = '>= 2.7.0'
  s.metadata['rubygems_mfa_required'] = 'true'

  s.add_dependency 'bundler', '~> 2.4'
  # s.add_dependency 'zeitwerk', '~> 2.6'

  s.add_development_dependency 'pry-byebug', '~> 3.10'
  # s.add_development_dependency 'rubocop', '~> 1.45'
  # s.add_development_dependency 'rubocop-minitest', '~> 0.28'
end
