# frozen_string_literal: true

require 'erb'

module Bundix
  module Nix
    # A service to render an {ERB} template.
    class Template
      attr_reader :context_class, :path

      # @param path [Pathname]
      # @param context_class [Class]
      def initialize(path, context_class: Context)
        @path = Pathname(path)
        @context_class = context_class
      end

      def call(**template_vars)
        erb_template.result(
          erb_context(**template_vars)
        )
      end

      private

      def erb_template
        ERB.new(path.read, trim_mode: '<>')
      end

      def erb_context(**options)
        context_class.new(**options).bind
      end
    end
  end
end
