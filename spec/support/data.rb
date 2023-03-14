# frozen_string_literal: true

module SpecDataDirHelpers
  def spec_data_dir
    @spec_data_dir ||= Pathname(__dir__).join('./data').expand_path.freeze
  end
end

RSpec.configure do |config|
  config.include SpecDataDirHelpers
  config.extend SpecDataDirHelpers
end
