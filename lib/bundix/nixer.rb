# frozen_string_literal: true

require 'erb'

module Bundix
  # Serializes ruby objects in nix syntax.
  class Nixer
    using Bundix::HashWithNixOrder

    SET_T = ERB.new(File.read(File.expand_path('../../template/nixer/set.erb', __dir__)).chomp)
    LIST_T = ERB.new(File.read(File.expand_path('../../template/nixer/list.erb', __dir__)).chomp)

    class << self
      def serialize(obj)
        new(obj).serialize
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

    attr_reader :level, :obj

    def initialize(obj, level = 0)
      @obj = obj
      @level = level
    end

    def indent
      ' ' * (level + 2)
    end

    def outdent
      ' ' * level
    end

    def sub(obj, indent = 0)
      self.class.new(obj, level + indent).serialize
    end

    def serialize_key(key)
      if key.to_s =~ /^[a-zA-Z_-]+[a-zA-Z0-9_-]*$/
        key.to_s
      else
        sub(key, 2)
      end
    end

    def serialize # rubocop:disable Metrics/AbcSize
      case obj
      when Hash then SET_T.result(binding)
      when Array then LIST_T.result(binding)
      when String then obj.dump
      when Symbol then obj.to_s.dump
      when Pathname then serialize_pathname(obj)
      when true, false then obj.to_s
      else
        raise "Cannot convert to nix: #{obj.inspect}"
      end
    end

    def serialize_pathname(path)
      str = path.to_s
      %r{/} =~ str ? str : "./#{str}"
    end
  end
end
