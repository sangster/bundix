# frozen_string_literal: true

RSpec.shared_context 'with gemdir' do |dir|
  include_context 'with gemset',
                  gemfile: Pathname(dir).join('Gemfile'),
                  lockfile: Pathname(dir).join('Gemfile.lock')
end
