# frozen_string_literal: true

RSpec.describe Bundix::Nix::Context do
  subject(:context) { described_class.new(**template_vars) }

  describe '#template_vars' do
    context 'when empty' do
      let(:template_vars) { {} }

      it { expect(context.template_vars).to be_empty }
      it { expect { context.test_variable }.to raise_error NoMethodError }
    end

    context 'with a variable' do
      let(:template_vars) { { test_variable: 'test value' } }

      it { expect(context.template_vars).to eq template_vars }
      it { expect(context.test_variable).to eq 'test value' }
    end
  end
end
