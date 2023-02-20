# frozen_string_literal: true

require_relative '../../test_helper'

class TestBundix < UnitTest
  def test_parse_gemset
    res = Bundix::App.new(gemset: 'test/data/path with space/gemset.nix').parse_gemset
    assert_equal({ 'a' => 1 }, res)
  end
end
