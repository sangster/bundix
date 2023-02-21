# frozen_string_literal: true

require_relative '../../test_helper'

class ConverterTest < UnitTest
  def test_parse_gemset
    res = Bundix::Converter.new(gemset: 'test/data/path with space/gemset.nix').parse_gemset

    assert_equal({ 'a' => 1 }, res)
  end
end
