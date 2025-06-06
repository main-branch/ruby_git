# frozen_string_literal: true

RSpec.describe RubyGit::CommandLine::Options do
  let(:options) { described_class.new(**options_hash) }
  let(:options_hash) { {} }

  it 'should be a subclass of ProcessExecuter::Options::RunOptions' do
    expect(described_class).to be < ProcessExecuter::Options::RunOptions
  end

  describe '#initialize' do
    subject { options }

    it 'should have attributes with default values' do
      expect(subject).to have_attributes(normalize_encoding: false, chomp: false)
    end

    context 'when options are passed' do
      let(:options_hash) { { normalize_encoding: true, chomp: true } }

      it 'should have the passed attributes' do
        expect(subject).to have_attributes(normalize_encoding: true, chomp: true)
      end
    end

    context 'when normalize_encoding is not valid' do
      let(:options_hash) { { normalize_encoding: 'not a boolean' } }

      it 'should raise an error' do
        expect { subject }.to raise_error(RubyGit::ArgumentError, /normalize_encoding/)
      end
    end

    context 'when chomp is not valid' do
      let(:options_hash) { { chomp: 'not a boolean' } }

      it 'should raise an error' do
        expect { subject }.to raise_error(RubyGit::ArgumentError, /chomp/)
      end
    end
  end
end
