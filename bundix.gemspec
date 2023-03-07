# frozen_string_literal: true

version = /VERSION\s*=\s*'([^']+)'/.match(File.read('lib/bundix/version.rb'))[1]

Gem::Specification.new do |s|
  s.name        = 'bundix'
  s.version     = version
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
end
