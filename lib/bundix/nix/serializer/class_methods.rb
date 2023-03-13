# frozen_string_literal: true

require 'erb'

module Bundix
  module Nix
    class Serializer
      # A mixin of class methods for {Serializer}.
      module ClassMethods
        def self.included(base)
          base.extend(Mixin)
        end

        # Defines the class methods.
        module Mixin
          def call(...)
            new(...).call
          end

          def erb_template(path)
            ERB.new(path.read.chomp).freeze
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
      end
    end
  end
end
