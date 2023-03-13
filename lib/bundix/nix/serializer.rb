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
    # - Any object that responds to +to_nix+
    class Serializer
      include ClassMethods
      using HashOrder

      DEFAULT_WIDTH = 80
      LIST_TEMPLATE = erb_template(TEMPLATES.join('serializer/list.erb'))
      SET_TEMPLATE = erb_template(TEMPLATES.join('serializer/set.erb'))

      attr_reader :compact_width, :level, :obj

      def initialize(obj, level = 0, compact_width: DEFAULT_WIDTH)
        @obj = obj
        @level = level
        @compact_width = compact_width - level if compact_width
      end

      def call
        case obj
        when Hash then compact_string(SET_TEMPLATE.result(binding))
        when Array then compact_string(LIST_TEMPLATE.result(binding))
        when String, Symbol, Gem::Version then nix_string
        when Pathname then serialize_pathname(obj)
        when true, false then obj.to_s
        else
          serialize_by_method(obj)
        end
      end

      def to_nix(obj = self.obj)
        if obj.respond_to?(:to_nix)
          to_nix(obj.to_nix)
        elsif obj.is_a?(Hash)
          obj.entries.to_h { |k, v| [to_nix(k), to_nix(v)] }
        elsif obj.respond_to?(:map)
          obj.map { |elem| to_nix(elem) }
        else
          obj
        end
      end

      def order(...)
        self.class.order(...)
      end

      private

      def compact_string(str)
        return str unless compact_width

        oneliner = compact_braces(str.gsub(/\s*\n\s*/, ' '), ['[]'])
        oneliner.size < compact_width ? oneliner : str
      end

      def compact_braces(str, pairs)
        pairs.map(&:chars).each do |left, right|
          return [left, str[2..-3], right].join if wrapped?(str, left, right)
        end
        str
      end

      def wrapped?(str, left, right)
        str.start_with?("#{left} ") && str.end_with?(" #{right}")
      end

      def nix_string
        obj.is_a?(String) ? obj.dump : obj.to_s.dump
      end

      def indent
        ' ' * (level + 2)
      end

      def outdent
        ' ' * level
      end

      def sub(obj, indent = 0)
        self.class.call(obj, level + indent, compact_width: compact_width)
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

      def serialize_by_method(obj)
        raise "Cannot serialize: #{obj.inspect}" unless obj.respond_to?(:to_nix)

        nix = obj.to_nix
        nix.is_a?(String) ? nix : self.class.call(nix, level, compact_width: compact_width)
      end
    end
  end
end
