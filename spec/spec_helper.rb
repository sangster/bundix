# frozen_string_literal: true

unless ENV.key?('SKIP_COVERAGE')
  require 'simplecov'

  # SimpleCov generates files with odd permissions
  Pathname(__dir__).join('../coverage/assets').glob('**/*')
                   .map { _1.directory? ? _1.chmod(0o755) : _1.chmod(0o644) }

  SimpleCov.start do
    enable_coverage :branch
    primary_coverage :branch
    add_filter %r{^/spec/}
  end
end

require 'bundix'
require 'pry-byebug'
Dir[Pathname.new(__dir__).join('support', '**', '*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.shared_context_metadata_behavior = :apply_to_host_groups
end
