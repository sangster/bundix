# frozen_string_literal: true

module Bundix
  module Nix
    # A service class to convert 16-bit SHA-256 hashes into the 32-bit format
    # used by nix.
    #
    # @see https://nixos.org/manual/nix/stable/command-ref/nix-hash.html
    # @see https://github.com/NixOS/nix/blob/0507462c/src/nix/hash.cc
    # @see https://github.com/NixOS/nix/blob/0507462c/src/libutil/hash.cc
    class Hash32
      SHA256_BITS = 256
      SHA256_BYTES = SHA256_BITS / 8

      BASE32_CHARS = '0123456789abcdfghijklmnpqrsvwxyz'
      BASE32_SIZE = ((SHA256_BITS - 1) / 5) + 1

      def self.call(...)
        new.call(...)
      end

      def call(hash)
        return hash if SHA256_32.match?(hash) # already converted

        to_base32(parse_sha256(hash))
      end

      private

      def to_base32(data)
        (0...BASE32_SIZE).map do |n|
          b = n * 5
          byte_to_base32(data, b / 8, b % 8)
        end.reverse.join
      end

      def byte_to_base32(data, byte, bits_left)
        a = byte >= SHA256_BYTES - 1 ? 0 : data[byte + 1] << (8 - bits_left)
        b = data[byte] >> bits_left
        BASE32_CHARS[(a | b) & 0x1f]
      end

      def parse_sha256(str)
        (0...SHA256_BYTES).map do |i|
          high = parse_hex_digit(str[i * 2]) << 4
          low = parse_hex_digit(str[(i * 2) + 1])
          high | low
        end
      end

      def parse_hex_digit(chr)
        case chr
        when '0'..'9' then diff_char(chr, '0')
        when 'A'..'F' then diff_char(chr, 'A') + 10
        when 'a'..'f' then diff_char(chr, 'a') + 10
        else
          raise ArgumentError, "unexpected: #{chr}"
        end
      end

      def diff_char(chr, from)
        chr.ord - from.ord
      end
    end
  end
end
