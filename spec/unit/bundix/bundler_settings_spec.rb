# frozen_string_literal: true

RSpec.describe Bundix::BundlerSettings do
  subject(:settings) { described_class.new(*args, **kwargs) }

  let(:args) { [] }
  let(:kwargs) { [] }

  describe '#ignore_config?' do
    let(:kwargs) { { ignore_config: ignore } }

    context 'when BUNDLE_IGNORE_CONFIG is set' do
      include_context 'with env', 'BUNDLE_IGNORE_CONFIG' => 'true'

      context 'when ignore_config is nil' do
        let(:ignore) { nil }

        it { expect(settings).to be_ignore_config }
      end

      context 'when ignore_config is true' do
        let(:ignore) { true }

        it { expect(settings).to be_ignore_config }
      end

      context 'when ignore_config is false' do
        let(:ignore) { false }

        it { expect(settings).not_to be_ignore_config }
      end
    end

    context 'when BUNDLE_IGNORE_CONFIG is unset' do
      include_context 'with env', 'BUNDLE_IGNORE_CONFIG' => nil

      context 'when ignore_config is nil' do
        let(:ignore) { nil }

        it { expect(settings).not_to be_ignore_config }
      end

      context 'when ignore_config is true' do
        let(:ignore) { true }

        it { expect(settings).to be_ignore_config }
      end

      context 'when ignore_config is false' do
        let(:ignore) { false }

        it { expect(settings).not_to be_ignore_config }
      end
    end
  end
end
