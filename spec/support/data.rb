# frozen_string_literal: true

module SpecDataDirHelpers
  def spec_data_dir
    @spec_data_dir ||= Pathname.new(File.expand_path('./data', __dir__))
  end
end

RSpec.configure do |config|
  config.include SpecDataDirHelpers
  config.extend SpecDataDirHelpers
end
