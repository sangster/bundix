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
end
