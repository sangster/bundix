# frozen_string_literal: true

require 'fileutils'

# This shared context executes the test with $PWD set to a temporary directory
# containing a temporary +Gemfile+ and optional +.bundle/config+.
RSpec.shared_context 'with dir' do |bundler_credential: nil|
  let(:tmpdir) { Dir.mktmpdir }
  let(:gemfile_path) { File.join(tmpdir, 'Gemfile') }
  let(:bundler_credential) { bundler_credential }

  def write_credential
    FileUtils.mkdir("#{tmpdir}/.bundle")
    File.write("#{tmpdir}/.bundle/config",
               "---\nBUNDLE_127__0__0__1: #{bundler_credential}\n")
  end

  def stub_bundler_env
    old_gemfile = ENV.fetch('BUNDLE_GEMFILE', nil)
    old_ignore_config = ENV.fetch('BUNDLE_IGNORE_CONFIG', nil)

    ENV['BUNDLE_GEMFILE'] = gemfile_path
    ENV['BUNDLE_IGNORE_CONFIG'] = nil

    yield

    ENV['BUNDLE_GEMFILE'] = old_gemfile if old_gemfile
    ENV['BUNDLE_IGNORE_CONFIG'] = old_ignore_config if old_ignore_config
  end

  around do |test|
    File.write(gemfile_path, "source 'https://rubygems.org'\n")
    write_credential if bundler_credential

    Dir.chdir tmpdir do
      Bundler.reset!
      stub_bundler_env(&test)
    end
  ensure
    FileUtils.remove_entry(tmpdir)
  end
end
