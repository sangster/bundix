# frozen_string_literal: true

RSpec.describe Bundix::Converter do
  subject(:converter) { described_class.new(options) }

  describe '#parse_gemset' do
    subject(:gemset) { converter.parse_gemset }

    context 'when using the "./path with space/" test data' do
      let(:options) { { gemset: gemset_file } }
      let(:gemset_file) { 'spec/support/data/path with space/gemset.nix' }

      it { expect(gemset).to eq 'a' => 1 }
    end
  end
end
