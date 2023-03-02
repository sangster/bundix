# frozen_string_literal: true

module Bundix
  # A renfinement that changes {Hash} comparison to first sort entries via
  # {Budix::Nixes.order}.
  module HashWithNixOrder
    refine Hash do
      def <=>(other)
        return unless other.is_a?(Hash)

        larray = to_a.sort { |l, r| Bundix::Nix::Serializer.order(l, r) }
        rarray = other.to_a.sort { |l, r| Bundix::Nix::Serializer.order(l, r) }
        larray <=> rarray
      end
    end
  end
end
