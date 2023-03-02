# frozen_string_literal: true

RSpec.describe Bundix::Nix::Serializer do
  subject(:serializer) { described_class.new(ruby_object) }

  describe '#call' do
    subject(:nix_code) { serializer.call }

    context 'with an Array of Hashes' do
      let(:ruby_object) { [{ a: 'x', b: '7' }, { a: 'y', c: '8' }] }

      it do
        expect(nix_code).to eq <<~NIX.chomp
          [{
            a = "x";
            b = "7";
          } {
            a = "y";
            c = "8";
          }]
        NIX
      end
    end

    context 'with an Array of Strings' do
      let(:ruby_object) { %w[a 7 string] }

      it { expect(nix_code).to eq '["7" "a" "string"]' }
    end

    context 'with a Hash' do
      let(:ruby_object) { { a: 'x', b: '7' } }

      it do
        expect(nix_code).to eq <<~NIX.chomp
          {
            a = "x";
            b = "7";
          }
        NIX
      end
    end

    context 'with a Pathname' do
      let(:ruby_object) { Pathname.new('.') }

      it { expect(nix_code).to eq './.' }
    end
  end
end
