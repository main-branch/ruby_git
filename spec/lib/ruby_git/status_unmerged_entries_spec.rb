# frozen_string_literal: true

require 'ruby_git/status'

RSpec.describe RubyGit::Status do
  describe '.parse' do
    let(:report) { described_class.parse(data) }

    describe 'unmerged change entries' do
      subject { report.entries.first }
      let(:entry_class) { RubyGit::Status::UnmergedEntry }

      describe 'attributes' do
        subject { report.entries.first }

        let(:data) do
          'u UU N... 100644 100755 000000 100755 ' \
            '1111111111111111111111111111111111111111 2222222222222222222222222222222222222222 ' \
            '3333333333333333333333333333333333333333 file1.txt' \
            "\u0000"
        end

        let(:expected_attributes) do
          {
            conflict_type: :both_modified,
            submodule_status: nil,
            base_mode: 0o100644,
            our_mode: 0o100755,
            their_mode: 0o000000,
            worktree_mode: 0o100755,
            base_sha: '1111111111111111111111111111111111111111',
            our_sha: '2222222222222222222222222222222222222222',
            their_sha: '3333333333333333333333333333333333333333',
            path: 'file1.txt'
          }
        end

        it { is_expected.to be_a(entry_class) }
        it { is_expected.to have_attributes(expected_attributes) }
      end

      # 'DD' => :both_deleted,
      # 'AU' => :added_by_us,
      # 'UD' => :deleted_by_them,
      # 'UA' => :added_by_them,
      # 'DU' => :deleted_by_us,
      # 'AA' => :both_added,
      # 'UU' => :both_modified

      describe 'conflict types' do
        let(:data) do
          "u #{conflict_type_code} N... 100644 100755 000000 100755 " \
            '1111111111111111111111111111111111111111 2222222222222222222222222222222222222222 ' \
            '3333333333333333333333333333333333333333 file1.txt' \
            "\u0000"
        end

        context 'when both sides have deleted the file' do
          let(:conflict_type_code) { 'DD' }
          it { is_expected.to have_attributes(conflict_type: :both_deleted) }
        end

        context 'when the file was added by us' do
          let(:conflict_type_code) { 'AU' }
          it { is_expected.to have_attributes(conflict_type: :added_by_us) }
        end

        context 'when the file was deleted by them' do
          let(:conflict_type_code) { 'UD' }
          it { is_expected.to have_attributes(conflict_type: :deleted_by_them) }
        end

        context 'when the file was added by them' do
          let(:conflict_type_code) { 'UA' }
          it { is_expected.to have_attributes(conflict_type: :added_by_them) }
        end

        context 'when the file was deleted by us' do
          let(:conflict_type_code) { 'DU' }
          it { is_expected.to have_attributes(conflict_type: :deleted_by_us) }
        end

        context 'when the file was added by both' do
          let(:conflict_type_code) { 'AA' }
          it { is_expected.to have_attributes(conflict_type: :both_added) }
        end

        context 'when the file was modified by both' do
          let(:conflict_type_code) { 'UU' }
          it { is_expected.to have_attributes(conflict_type: :both_modified) }
        end
      end
    end
  end
end
