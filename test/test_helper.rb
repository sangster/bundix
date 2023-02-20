# frozen_string_literal: true

require 'minitest/autorun'
require 'bundix'
require 'pry-byebug'

Pathname.new(__dir__)
        .join('support')
        .glob('**/*.rb')
        .each { |file| require file }

class UnitTest < Minitest::Test
end
