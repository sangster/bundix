# frozen_string_literal: true

module Bundix
  module Nix
    class Serializer
      # A renfinement that changes {Hash} comparison to first sort entries via
      # {Serializer.order}.
      module HashOrder
        refine Hash do
          def <=>(other)
            return unless other.is_a?(Hash)

            larray = to_a.sort { |l, r| Serializer.order(l, r) }
            rarray = other.to_a.sort { |l, r| Serializer.order(l, r) }
            larray <=> rarray
          end
        end
      end
    end
  end
end
