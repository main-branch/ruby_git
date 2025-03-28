# frozen_string_literal: true

require 'ruby_git/status'

RSpec.describe RubyGit::Status do
  describe '.parse' do
    let(:report) { described_class.parse(data) }
    subject { report }

    context 'with empty output' do
      let(:data) { '' }

      it { is_expected.to be_a(RubyGit::Status::Report) }
    end

    describe 'branch information' do
      subject { report.branch }

      context 'without branch information' do
        let(:data) { '' }
        it { is_expected.to be_nil }
      end

      context 'an empty repository' do
        # :nocov: not run in the test suite
        def reproduce_data
          in_temp_dir do
            run %w[git init --initial-branch=main]
            status_output_to_ruby_string
          end
        end
        # :nocov:

        let(:data) do
          "# branch.oid (initial)\u0000" \
            "# branch.head main\u0000"
        end

        let(:expected_attributes) do
          {
            name: 'main',
            oid: nil,
            detached?: false,
            upstream: nil,
            upstream?: false,
            ahead: nil,
            behind: nil
          }
        end

        it { is_expected.to have_attributes(expected_attributes) }
      end

      context 'a branch with no upstream' do
        # :nocov: not run in the test suite
        def reproduce_data
          in_temp_dir do
            run %w[git init --initial-branch=main]
            run %w[git commit --allow-empty -m commit_1]
            status_output_to_ruby_string
          end
        end
        # :nocov:

        let(:data) do
          "# branch.oid 9997b1ca0866e93f8ae5c2f815ebe179987696bc\u0000" \
            "# branch.head main\u0000"
        end

        let(:expected_attributes) do
          {
            name: 'main',
            oid: '9997b1ca0866e93f8ae5c2f815ebe179987696bc',
            detached?: false,
            upstream: nil,
            upstream?: false,
            ahead: nil,
            behind: nil
          }
        end

        it { is_expected.to have_attributes(expected_attributes) }
      end

      context 'with an empty upstream' do
        # :nocov: not run in the test suite
        def reproduce_data
          in_temp_dir do
            FileUtils.mkdir('remote')
            FileUtils.mkdir('worktree')
            Dir.chdir('remote') { run %w[git init --bare --initial-branch=main] }
            Dir.chdir('worktree') do
              run %w[git clone ../remote .]
              status_output_to_ruby_string
            end
          end
        end
        # :nocov:

        let(:data) do
          "# branch.oid (initial)\u0000" \
            "# branch.head main\u0000" \
            "# branch.upstream origin/main\u0000"
        end

        let(:expected_attributes) do
          {
            name: 'main',
            oid: nil,
            detached?: false,
            upstream: 'origin/main',
            upstream?: true,
            ahead: nil,
            behind: nil
          }
        end

        it { is_expected.to have_attributes(expected_attributes) }
      end

      context 'with an non-empty upstream' do
        # :nocov: not run in the test suite
        def reproduce_data
          in_temp_dir do
            FileUtils.mkdir('remote')
            FileUtils.mkdir('worktree')
            Dir.chdir('remote') { run %w[git init --bare --initial-branch=main] }
            Dir.chdir('worktree') do
              run %w[git clone ../remote .]
              run %w[git commit --allow-empty -m commit_1]
              run %w[git push -u origin main]
              status_output_to_ruby_string
            end
          end
        end
        # :nocov:

        let(:data) do
          "# branch.oid 3fa66bc8b68b5ec278566c6a0b4c3433289bad89\u0000" \
            "# branch.head main\u0000" \
            "# branch.upstream origin/main\u0000" \
            "# branch.ab +0 -0\u0000"
        end

        let(:expected_attributes) do
          {
            name: 'main',
            oid: '3fa66bc8b68b5ec278566c6a0b4c3433289bad89',
            detached?: false,
            upstream: 'origin/main',
            upstream?: true,
            ahead: 0,
            behind: 0
          }
        end

        it { is_expected.to have_attributes(expected_attributes) }
      end

      context 'with non-zero ahead and behind' do
        # :nocov: not run in the test suite
        def reproduce_data
          in_temp_dir do
            FileUtils.mkdir('remote')
            FileUtils.mkdir('worktree')
            Dir.chdir('remote') { run %w[git init --bare --initial-branch=main] }
            Dir.chdir('worktree') do
              run %w[git clone ../remote .]
              run %w[git commit --allow-empty -m commit_1]
              run %w[git commit --allow-empty -m commit_2]
              run %w[git push -u origin main]
              run %w[git reset HEAD~1]
              run %w[git commit --allow-empty -m commit_3]
              run %w[git commit --allow-empty -m commit_4]
              status_output_to_ruby_string
            end
          end
        end
        # :nocov:

        let(:data) do
          "# branch.oid 7abbaae62d46da1a8ee1418357590a3a10cb1000\u0000" \
            "# branch.head main\u0000" \
            "# branch.upstream origin/main\u0000" \
            "# branch.ab +2 -1\u0000"
        end

        let(:expected_attributes) do
          {
            name: 'main',
            oid: '7abbaae62d46da1a8ee1418357590a3a10cb1000',
            detached?: false,
            upstream: 'origin/main',
            upstream?: true,
            ahead: 2,
            behind: 1
          }
        end

        it { is_expected.to have_attributes(expected_attributes) }
      end

      context 'with detached HEAD' do
        # :nocov: not run in the test suite
        def reproduce_data
          in_temp_dir do
            run %w[git init --initial-branch=main]
            run %w[git commit --allow-empty -m commit_1]
            run %w[git checkout --detach HEAD]
            status_output_to_ruby_string
          end
        end
        # :nocov:

        let(:data) do
          "# branch.oid 84f41101f9974f7a777199041a46963e457ec19f\u0000" \
            "# branch.head (detached)\u0000"
        end

        let(:expected_attributes) do
          {
            name: nil,
            oid: '84f41101f9974f7a777199041a46963e457ec19f',
            detached?: true,
            upstream: nil,
            upstream?: false,
            ahead: nil,
            behind: nil
          }
        end

        it { is_expected.to have_attributes(expected_attributes) }
      end
    end

    describe 'stash information' do
      subject { report.stash }

      context 'without stash information' do
        let(:data) { '' }
        it { is_expected.to have_attributes(count: 0) }
      end

      context 'with zero stashes' do
        # :nocov: not run in the test suite
        def reproduce_data
          in_temp_dir do
            run %w[git init --initial-branch=main]
            run %w[git commit --allow-empty -m commit_1]
            status_output_to_ruby_string
          end
        end
        # :nocov:

        let(:data) do
          "# branch.oid 8f1007c31e1a26313aaa3adbf974ce579de78921\u0000" \
            "# branch.head main\u0000"
        end

        it { is_expected.to have_attributes(count: 0) }
      end

      context 'with more than 0 stashes' do
        # :nocov: not run in the test suite
        def reproduce_data
          in_temp_dir do
            run %w[git init --initial-branch=main]
            run %w[git commit --allow-empty -m commit_1]
            File.write('file.txt', 'stash_1')
            run %w[git stash push -u -m stash_1]
            File.write('file.txt', 'stash_2')
            run %w[git stash push -u -m stash_2]
            File.write('file.txt', 'stash_3')
            run %w[git stash push -u -m stash_3]
            status_output_to_ruby_string
          end
        end
        # :nocov:

        let(:data) do
          "# branch.oid a354acac5d0be1a54855eca109b1668721a20d45\u0000" \
            "# branch.head main\u0000" \
            "# stash 3\u0000"
        end

        it { is_expected.to have_attributes(count: 3) }
      end
    end

    describe 'with an unknown header' do
      let(:data) { "# some_other_header value\u0000" }

      it 'ignores the unknown header' do
        expect { subject }.not_to raise_error
      end
    end

    describe 'filters' do
      let(:data) do
        '1 M. N... 000000 100644 100644 0000000000000000000000000000000000000000 ' \
          "49351eb5b7e355128f8f569d5b3355c3e2a51d4b file1.txt\u0000" \
          '1 MM N... 000000 100644 100644 0000000000000000000000000000000000000000 ' \
          "49351eb5b7e355128f8f569d5b3355c3e2a51d4b file2.txt\u0000" \
          '1 .M N... 000000 100644 100644 0000000000000000000000000000000000000000 ' \
          "49351eb5b7e355128f8f569d5b3355c3e2a51d4b file3.txt\u0000" \
          '2 RD N... 100644 100755 000000 1111111111111111111111111111111111111111 ' \
          "2222222222222222222222222222222222222222 R100 file4.txt\u0000" \
          "file4_old.txt\u0000" \
          '2 R. N... 100644 100755 000000 1111111111111111111111111111111111111111 ' \
          "2222222222222222222222222222222222222222 R100 file5.txt\u0000" \
          "file5_old.txt\u0000" \
          'u UU N... 100644 100755 000000 100755 ' \
          '1111111111111111111111111111111111111111 2222222222222222222222222222222222222222 ' \
          '3333333333333333333333333333333333333333 file6.txt' \
          "\u0000" \
          "? file7.txt\u0000" \
          "? file8.txt\u0000" \
          "! file9.txt\u0000"
      end

      describe '#ignored' do
        subject { report.ignored }
        it 'should return the ignored entries' do
          expect(subject.map(&:path)).to eq(%w[file9.txt])
        end
      end

      describe '#untracked' do
        subject { report.untracked }
        it 'should return the untracked entries' do
          expect(subject.map(&:path)).to eq(%w[file7.txt file8.txt])
        end
      end

      describe '#unstaged' do
        subject { report.unstaged }
        it 'should return the unstaged entries' do
          expect(subject.map(&:path)).to eq(%w[file2.txt file3.txt file4.txt file7.txt file8.txt])
        end
      end

      describe '#staged' do
        subject { report.staged }
        it 'should return the staged entries' do
          expect(subject.map(&:path)).to eq(%w[file1.txt file2.txt file4.txt file5.txt])
        end
      end

      describe '#fully_staged' do
        subject { report.fully_staged }
        it 'should return the fully staged entries' do
          expect(subject.map(&:path)).to eq(%w[file1.txt file5.txt])
        end
      end

      describe '#unmerged' do
        subject { report.unmerged }
        it 'should return the unmerged entries' do
          expect(subject.map(&:path)).to eq(%w[file6.txt])
        end
      end
    end

    describe '#merge_conflict?' do
      subject { report.merge_conflict? }
      context 'when there is a merge conflict' do
        let(:data) do
          'u UU N... 100644 100755 000000 100755 ' \
            '1111111111111111111111111111111111111111 2222222222222222222222222222222222222222 ' \
            '3333333333333333333333333333333333333333 file6.txt'
        end

        it { is_expected.to eq(true) }
      end

      context 'when there is not a merge conflict' do
        let(:data) { '' }
        it { is_expected.to eq(false) }
      end
    end
  end
end
