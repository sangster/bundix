# frozen_string_literal: true

RSpec.describe Bundix::Nix::RubyToNix do
  subject :ruby_to_nix do
    described_class.new(dest, serializer_class: serializer_class)
  end

  let :serializer_class do
    Struct.new('Serializer', :serialized_string) do
      def call
        serialized_string
      end
    end
  end

  describe '#call' do
    subject(:body) { ruby_to_nix.call(serialized_string) && dest.read }

    let(:dest) { Tempfile.new(%w[ruby_to_nix- .nix]) }
    let(:serialized_string) { '{ serialized = "nix code"; }' }

    around do |test|
      test.call
    ensure
      dest.unlink
    end

    it { expect(body).to start_with serialized_string }
    it { expect(body).to end_with "\n" }
  end
end
