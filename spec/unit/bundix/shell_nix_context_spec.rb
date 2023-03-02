# frozen_string_literal: true

RSpec.describe Bundix::ShellNixContext do
  subject(:context) { described_class.new(**options) }

  let(:options) { {} }

  describe '.members' do
    subject(:members) { described_class.members }

    it 'has the expected Struct members' do
      expect(members).to contain_exactly :project, :ruby, :gemfile, :lockfile,
                                         :gemset
    end
  end

  described_class.members.each do |member|
    describe "##{member}" do
      context 'when uninitialized' do
        it { expect(context.send(member)).to be_nil }
      end

      context 'when initialized' do
        let(:options) { { member => "#{member}-test" } }

        it { expect(context.send(member)).to eq "#{member}-test" }
      end
    end
  end
end
