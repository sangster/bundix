# frozen_string_literal: true

require 'fileutils'
require 'tempfile'

module Bundix
  module Nix
    # A service to convert a ruby object to nix code and write the result to a
    # file.
    class RubyToNix
      attr_reader :dest, :mode, :serializer_class

      # @param dest [Pathname] The location to write the resulting nix source
      #   file.
      # @param mode [Integer] The created file's mode bits.
      # @param serializer_class [Class] The service class to render the object
      #   into nix code.
      def initialize(dest, mode: 0o644, serializer_class: Serializer)
        @dest = Pathname(dest)
        @mode = mode
        @serializer_class = serializer_class
      end

      # @param obj [Object] The ruby object to render into nix code, to
      #   {#dest}.
      # @note The types of ruby objects which can be rendered will be determined
      #   by {#serializer_class}.
      def call(obj)
        tempfile = Tempfile.new('ruby.nix', encoding: 'UTF-8')
        tempfile.write(serializer_class.new(obj).call)
        tempfile.write("\n")
        tempfile.flush

        FileUtils.cp(tempfile.path, dest)
        FileUtils.chmod(mode, dest)
      ensure
        tempfile.close!
        tempfile.unlink
      end
    end
  end
end
