# frozen_string_literal: true

RSpec.shared_context 'with gemset' do |options|
  let :gemset_options do
    { deps: false, lockfile: '', gemset: '' }.merge(options)
  end
  let :converter do
    Bundix::Converter.new(gemset_options).tap do |conv|
      conv.fetcher = PrefetchStub.new
    end
  end
  let(:gemset) { converter.convert }

  around do |test|
    Bundler.instance_variable_set(:@root, spec_data_dir)

    old_gemfile = ENV.fetch('BUNDLE_GEMFILE', nil)
    ENV['BUNDLE_GEMFILE'] = gemset_options[:gemfile].to_s

    test.call
  ensure
    ENV['BUNDLE_GEMFILE'] = old_gemfile if old_gemfile
    Bundler.reset!
  end
end

class PrefetchStub
  def nix_prefetch_url(*_args)
    'nix_prefetch_url_hash'
  end

  def nix_prefetch_git(_uri, _revision)
    '{"sha256": "nix_prefetch_git_hash"}'
  end

  def fetch_local_hash(_spec)
    # Example hash taken from `man nix-hash`.
    '5891b5b522d5df086d0ff0b110fbd9d21bb4fc7163af34d08286a2e846f6be03'
  end

  def fetch_remotes_hash(_spec, _remotes)
    'fetch_remotes_hash_hash'
  end
end
