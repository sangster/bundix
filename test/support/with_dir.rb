# frozen_string_literal: true

require 'tmpdir'

module WithDir
  # Executes a block with CWD set to a temporary directory containing a
  # mostly-empty Gemfile.
  #
  # @param bundler_credential [nil,String] Optional credentials for an HTTP
  #   gem source running at 127.0.0.1.
  def with_dir(bundler_credential: nil)
    Dir.mktmpdir do |dir|
      File.write("#{dir}/Gemfile", 'source "https://rubygems.org"')
      write_credential(dir, bundler_credential) if bundler_credential

      Dir.chdir dir do
        Bundler.reset!
        yield dir
      end
    end
  end

  private

  def write_credential(dir, bundler_credential)
    FileUtils.mkdir("#{dir}/.bundle")
    File.write("#{dir}/.bundle/config",
               "---\nBUNDLE_127__0__0__1: #{bundler_credential}\n")
  end
end
