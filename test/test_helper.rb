# frozen_string_literal: true

require 'minitest/autorun'
require 'bundix'
require 'pry-byebug'

Pathname.new(__dir__)
        .join('support')
        .glob('**/*.rb')
        .each { |file| require file }

# The base class for all unit tests.
class UnitTest < Minitest::Test
  def before_setup
    quiet_by_default
  end

  def after_teardown
    restore_verbose
  end

  private

  def quiet_by_default
    @old_verbose = $VERBOSE
    $VERBOSE = nil
  end

  def restore_verbose
    $VERBOSE = @old_verbose
  end
end
