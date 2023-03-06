# frozen_string_literal: true

RSpec.describe Bundix::Nix::Hash32 do
  describe '#call' do
    subject(:base32) { described_class.new.call(sha256) }

    {
      'd3ee00f26c151763da1691c7fc6871ddd03e532f74f85101f5acedc2d099e958' =>
        '0n79k78c5vdcyl0m3y3l5x9kxl6xf5lgriwi2vd665qmdkr01vnk',
      'ec0f3405996434ea70396807394e16897235264327c011aabd3c2d202508006d' =>
        '0v8010jj0b9wpnm13h178ck3awl92r73j1v875qfld34k42k83zc'
    }.each do |hash, expected|
      context "with the 16-bit hash '#{hash}'" do
        let(:sha256) { hash }

        it { expect(base32).to eq expected }
      end
    end

    %w[
      0n79k78c5vdcyl0m3y3l5x9kxl6xf5lgriwi2vd665qmdkr01vnk
      0v8010jj0b9wpnm13h178ck3awl92r73j1v875qfld34k42k83zc
    ].each do |hash|
      context "with the already-converted 32-bit hash '#{hash}'" do
        let(:sha256) { hash }

        it { expect(base32).to eq hash }
      end
    end

    context 'with an illegal character' do
      let(:sha256) { '?' }

      it { expect { base32 }.to raise_error ArgumentError, 'unexpected: ?' }
    end
  end
end
