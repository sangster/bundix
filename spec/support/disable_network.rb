# frozen_string_literal: true

# Disable network access so tests don't accidentally clone remote git repos or
# hammer a RubyGems API.
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)
