# frozen_string_literal: true

module Bundix
  module Nix
    # The ERB context when rendering the +shell.nix+ ERB template. The methods
    # of this class will be available to the template as variables.
    class Context
      attr_reader :template_vars

      # @param template_vars [Hash] A collection of variables to be made
      #   available to the ERB template.
      def initialize(**template_vars)
        @template_vars = template_vars
      end

      def method_missing(name, *args, &block)
        template_vars.key?(name) ? template_vars[name] : super
      end

      def respond_to_missing?(name, include_private = false)
        template_vars.key?(name) || super
      end

      # @return [Binding]
      def bind
        binding
      end

      def path_for(file)
        Serializer.call(Pathname(file).relative_path_from(Pathname('./')))
      end

      def gemfile_path
        path_for(gemfile)
      end

      def lockfile_path
        path_for(lockfile)
      end

      def gemset_path
        path_for(gemset)
      end
    end
  end
end
