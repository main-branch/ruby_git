# frozen_string_literal: true

require 'ruby_git/status'

RSpec.describe RubyGit::Status do
  describe '.parse' do
    let(:report) { described_class.parse(data) }

    describe 'untracked change entries' do
      subject { report.entries.first }
      let(:entry_class) { RubyGit::Status::UntrackedEntry }

      describe 'attributes' do
        let(:data) do
          '? file1.txt'
        end

        let(:expected_attributes) do
          { path: 'file1.txt' }
        end

        it { is_expected.to be_a(entry_class) }
        it { is_expected.to have_attributes(expected_attributes) }
      end
    end
  end
end
