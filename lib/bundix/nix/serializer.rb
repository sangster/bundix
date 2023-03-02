# frozen_string_literal: true

require 'erb'

module Bundix
  module Nix
    # Serializes ruby objects in nix syntax.
    #
    # = Supported ruby objects
    #
    # - {Hash}, where the keys and values are also supported
    # - {Array}, where the elements are also supported
    # - {String}
    # - {Symbol}
    # - {Pathname}
    # - {TrueClass true} and {FalseClass false}
    class Serializer
      using Bundix::HashWithNixOrder

      SET_TEMPLATE = '../../../template/nixer/set.erb'
      LIST_TEMPLATE = '../../../template/nixer/list.erb'

      attr_reader :level, :obj

      class << self
        def call(...)
          new(...).call
        end

        def order(left, right)
          if right.is_a?(left.class) && right.respond_to?(:<=>)
            cmp = right <=> left
            return -1 * cmp unless cmp.nil?
          end

          if left.is_a?(right.class) && left.respond_to?(:<=>)
            cmp = right <=> left
            return class_order(left, right) if cmp.nil?

            return cmp
          end

          class_order(left, right)
        end

        def class_order(left, right)
          left.class.name <=> right.class.name # like Erlang
        end
      end

      def initialize(obj, level = 0)
        @obj = obj
        @level = level
      end

      def call # rubocop:disable Metrics/AbcSize
        case obj
        when Hash then set_template.result(binding)
        when Array then list_template.result(binding)
        when String then obj.dump
        when Symbol then obj.to_s.dump
        when Pathname then serialize_pathname(obj)
        when true, false then obj.to_s
        else
          raise "Cannot convert to nix: #{obj.inspect}"
        end
      end

      def order(...)
        self.class.order(...)
      end

      private

      def set_template
        @set_template ||= erb_template(SET_TEMPLATE)
      end

      def list_template
        @list_template ||= erb_template(LIST_TEMPLATE)
      end

      def erb_template(path)
        ERB.new(Pathname(__dir__).join(path).read.chomp)
      end

      def indent
        ' ' * (level + 2)
      end

      def outdent
        ' ' * level
      end

      def sub(obj, indent = 0)
        self.class.call(obj, level + indent)
      end

      def serialize_key(key)
        if key.to_s =~ /^[a-zA-Z_-]+[a-zA-Z0-9_-]*$/
          key.to_s
        else
          sub(key, 2)
        end
      end

      def serialize_pathname(path)
        str = path.to_s
        %r{/} =~ str ? str : "./#{str}"
      end
    end
  end
end
