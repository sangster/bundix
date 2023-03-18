# frozen_string_literal: true

RSpec.shared_context 'with bundle' do |gemdir|
  let(:gemfile) { Pathname(gemdir).join('Gemfile') }
  let(:lockfile) { Pathname(gemdir).join('Gemfile.lock') }
  let(:definition) do
    Bundler::Definition.build(gemfile.to_s, lockfile.to_s, false)
  end
end
