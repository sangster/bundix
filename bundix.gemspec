# frozen_string_literal: true

require_relative 'lib/bundix/version'

Gem::Specification.new do |s|
  s.name        = 'bundix'
  s.version     = Bundix::VERSION
  s.licenses    = ['MIT']
  s.homepage    = 'https://github.com/manveru/bundix'
  s.summary     = 'Creates Nix packages from Gemfiles.'
  s.description = 'Creates Nix packages from Gemfiles.'
  s.authors     = ["Michael 'manveru' Fellinger"]
  s.files       = Dir['bin/*'] +
                  Dir['lib/**/*.{rb,nix,erb}'] +
                  Dir['template/**/*.{rb,nix,erb}']
  s.bindir      = 'bin'
  s.executables = ['bundix']
  s.required_ruby_version = '>= 2.7.0'

  s.metadata['rubygems_mfa_required'] = 'true'

  s.add_dependency 'bundler', '~> 2.4'
  s.add_dependency 'zeitwerk', '~> 2.6'

  s.add_development_dependency 'pry-byebug', '~> 3.10'
  s.add_development_dependency 'rubocop', '~> 1.45'
  s.add_development_dependency 'rubocop-minitest', '~> 0.28'
end
