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
  end
end
