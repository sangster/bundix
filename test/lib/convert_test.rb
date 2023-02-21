# frozen_string_literal: true

require_relative '../test_helper'

class ConvertTest < UnitTest
  include WithGemset

  def test_bundler_dep
    with_gemset(
      gemfile: File.expand_path('../data/bundler-audit/Gemfile', __dir__),
      lockfile: File.expand_path('../data/bundler-audit/Gemfile.lock', __dir__)
    ) do |gemset|
      assert_equal('0.5.0', gemset.dig('bundler-audit', :version))
      assert_equal('0.19.4', gemset.dig('thor', :version))
    end
  end

  def test_gemspec_dep
    with_gemset(
      gemfile: File.expand_path('../data/gemspec/Gemfile', __dir__),
      lockfile: File.expand_path('../data/gemspec/Gemfile.lock', __dir__)
    ) do |gemset|
      assert_equal('0.1.0', gemset.dig('example', :version))
      assert_equal('1.45.1', gemset.dig('rubocop', :version))
    end
  end

  def test_gemspec_missing
    assert_raises Bundler::Dsl::DSLError do
      with_gemset(
        gemfile: File.expand_path('../data/gemspec-missing/Gemfile', __dir__),
        lockfile: File.expand_path('../data/gemspec-missing/Gemfile.lock', __dir__)
      )
    end
  end
end
