# frozen_string_literal: true

require 'bundix'
require 'pry-byebug'
Dir[Pathname.new(__dir__).join('support', '**', '*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.shared_context_metadata_behavior = :apply_to_host_groups
end
