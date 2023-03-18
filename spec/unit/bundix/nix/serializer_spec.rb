# frozen_string_literal: true

RSpec.describe Bundix::Nix::Serializer do
  subject(:serializer) do
    described_class.new(ruby_object, compact_width: compact_width)
  end

  describe '#call' do
    subject(:nix_code) { serializer.call }

    context 'with an Array of Hashes' do
      let(:ruby_object) { [{ a: 'x', b: '7' }, { a: 'y', c: '8' }] }

      context 'with no compact_width' do
        let(:compact_width) { nil }

        it do
          expect(nix_code).to eq <<~NIX.chomp
            [
              {
                a = "x";
                b = "7";
              }
              {
                a = "y";
                c = "8";
              }
            ]
          NIX
        end
      end

      context 'with default compact_width' do
        let(:compact_width) { described_class::DEFAULT_WIDTH }

        it do
          expect(nix_code).to eq '[{ a = "x"; b = "7"; } { a = "y"; c = "8"; }]'
        end
      end
    end

    context 'with an Array of Strings' do
      let(:ruby_object) { %w[a 7 string] }

      context 'with no compact_width' do
        let(:compact_width) { nil }

        it do
          expect(nix_code).to eq <<~NIX.chomp
            [
              "7"
              "a"
              "string"
            ]
          NIX
        end
      end

      context 'with default compact_width' do
        let(:compact_width) { described_class::DEFAULT_WIDTH }

        it { expect(nix_code).to eq '["7" "a" "string"]' }
      end
    end

    context 'with a Hash' do
      let(:ruby_object) { { a: 'x', b: '7' } }

      context 'with no compact_width' do
        let(:compact_width) { nil }

        it do
          expect(nix_code).to eq <<~NIX.chomp
            {
              a = "x";
              b = "7";
            }
          NIX
        end
      end

      context 'with default compact_width' do
        let(:compact_width) { described_class::DEFAULT_WIDTH }

        it { expect(nix_code).to eq '{ a = "x"; b = "7"; }' }
      end
    end

    context 'with a Pathname' do
      let(:ruby_object) { Pathname.new('.') }

      context 'with no compact_width' do
        let(:compact_width) { nil }

        it { expect(nix_code).to eq './.' }
      end
    end
  end
end
