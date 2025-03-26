# frozen_string_literal: true

require 'ruby_git/status'

RSpec.describe RubyGit::Status do
  describe '.parse' do
    let(:report) { described_class.parse(data) }

    describe 'renamed change entries' do
      subject { report.entries.first }
      let(:entry_class) { RubyGit::Status::RenamedEntry }

      describe 'attributes' do
        subject { report.entries.first }

        let(:data) do
          '2 RD N... 100644 100755 000000 1111111111111111111111111111111111111111 ' \
            "2222222222222222222222222222222222222222 R100 file2.txt\u0000" \
            "file1.txt\u0000"
        end

        let(:expected_attributes) do
          {
            index_status: :renamed,
            worktree_status: :deleted,
            head_mode: 0o100644,
            index_mode: 0o100755,
            worktree_mode: 0o000000,
            head_sha: '1111111111111111111111111111111111111111',
            index_sha: '2222222222222222222222222222222222222222',
            operation: :rename,
            path: 'file2.txt',
            original_path: 'file1.txt'
          }
        end

        it { is_expected.to be_a(entry_class) }
        it { is_expected.to have_attributes(expected_attributes) }
      end

      describe 'worktree modifications' do
        context 'when unmodified in the worktree' do
          subject { report.entries.first }

          # :nocov: not run in the test suite
          def reproduce_data
            in_temp_dir do
              run %w[git init --initial-branch=main]
              File.write 'file1.txt', 'File 1'
              run %w[git add file1.txt]
              run %w[git commit -m commit_1]
              run %w[git mv file1.txt file2.txt]

              status_output_to_ruby_string
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid 9122960001e81fa4916508182ea54b9f37d94e5d\u0000" \
              "# branch.head main\u0000" \
              '2 R. N... 100644 100644 100644 49351eb5b7e355128f8f569d5b3355c3e2a51d4b ' \
              "49351eb5b7e355128f8f569d5b3355c3e2a51d4b R100 file2.txt\u0000" \
              "file1.txt\u0000"
          end

          it { is_expected.to be_a(entry_class) }
          it { is_expected.to have_attributes(worktree_status: :unmodified) }
        end

        context 'when modified in the worktree' do
          # :nocov: not run in the test suite
          def reproduce_data
            in_temp_dir do
              run %w[git init --initial-branch=main]
              File.write 'file1.txt', 'File 1'
              run %w[git add file1.txt]
              run %w[git commit -m commit_1]
              run %w[git mv file1.txt file2.txt]
              File.write 'file2.txt', 'File 1 with modifications'

              status_output_to_ruby_string
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid aa7798b5c8b523d6c13c2fbe2662720bb4150900\u0000" \
              "# branch.head main\u0000" \
              '2 RM N... 100644 100644 100644 49351eb5b7e355128f8f569d5b3355c3e2a51d4b ' \
              "49351eb5b7e355128f8f569d5b3355c3e2a51d4b R100 file2.txt\u0000" \
              "file1.txt\u0000"
          end

          it { is_expected.to be_a(entry_class) }
          it { is_expected.to have_attributes(worktree_status: :modified) }
        end

        context 'when the type is changed in the worktree' do
          # :nocov: not run in the test suite
          def reproduce_data
            in_temp_dir do
              run %w[git init --initial-branch=main]
              File.write 'file1.txt', 'File 1'
              run %w[git add file1.txt]
              run %w[git commit -m commit_1]
              run %w[git mv file1.txt file2.txt]
              File.delete 'file2.txt'
              File.symlink File::NULL, 'file2.txt'

              status_output_to_ruby_string
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid 60914f2885bbab8e8ea92f5b54a5223eed989b9b\u0000" \
              "# branch.head main\u0000" \
              '2 RT N... 100644 100644 120000 49351eb5b7e355128f8f569d5b3355c3e2a51d4b ' \
              "49351eb5b7e355128f8f569d5b3355c3e2a51d4b R100 file2.txt\u0000" \
              "file1.txt\u0000"
          end

          it { is_expected.to be_a(entry_class) }
          it { is_expected.to have_attributes(worktree_status: :type_changed) }
        end

        context 'when deleted from the worktree' do
          # :nocov: not run in the test suite
          def reproduce_data
            in_temp_dir do
              run %w[git init --initial-branch=main]
              File.write 'file1.txt', 'File 1'
              run %w[git add file1.txt]
              run %w[git commit -m commit_1]
              run %w[git mv file1.txt file2.txt]
              File.delete 'file2.txt'

              status_output_to_ruby_string
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid ef763a83e94b18cf711142759acec98711837465\u0000" \
              "# branch.head main\u0000" \
              '2 RD N... 100644 100644 000000 49351eb5b7e355128f8f569d5b3355c3e2a51d4b ' \
              "49351eb5b7e355128f8f569d5b3355c3e2a51d4b R100 file2.txt\u0000" \
              "file1.txt\u0000"
          end

          it { is_expected.to be_a(entry_class) }
          it { is_expected.to have_attributes(worktree_status: :deleted) }
        end
      end

      describe 'index modifications' do
        context 'when renamed in the index' do
          # :nocov: not run in the test suite
          def reproduce_data
            in_temp_dir do
              run %w[git init --initial-branch=main]
              File.write 'file1.txt', 'File 1'
              run %w[git add file1.txt]
              run %w[git commit -m commit_1]
              run %w[git mv file1.txt file2.txt]

              status_output_to_ruby_string
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid b24df6c0b7deb8800f77a4fe74ac2be7c7a12ca4\u0000" \
              "# branch.head main\u0000" \
              '2 R. N... 100644 100644 100644 49351eb5b7e355128f8f569d5b3355c3e2a51d4b ' \
              "49351eb5b7e355128f8f569d5b3355c3e2a51d4b R100 file2.txt\u0000" \
              "file1.txt\u0000"
          end

          it { is_expected.to be_a(entry_class) }
          it { is_expected.to have_attributes(index_status: :renamed) }
        end
      end

      describe 'submodule modifications' do
        subject { report.entries.first.submodule_status }

        context 'when the entry is not a submodule' do
          # :nocov: not run in the test suite
          def reproduce_data
            in_temp_dir do
              run %w[git init --initial-branch=main]
              File.write 'file1.txt', 'File 1'
              run %w[git add file1.txt]
              status_output_to_ruby_string
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid (initial)\u0000" \
              "# branch.head main\u0000" \
              '1 A. N... 000000 100644 100644 0000000000000000000000000000000000000000 ' \
              "49351eb5b7e355128f8f569d5b3355c3e2a51d4b file1.txt\u0000"
          end

          it { is_expected.to be_nil }
        end

        context 'when the entry is a submodule with no changes' do
          subject { report.entries.find { |e| e.path == 'submodule_path' } }

          # :nocov: not run in the test suite
          def reproduce_data
            in_temp_dir do
              in_dir 'submodule_remote' do
                run %w[git init --bare --initial-branch=main]
              end

              in_dir 'submodule_work_tree' do
                run %w[git clone ../submodule_remote .]
                File.write 'file1.txt', 'Submodule file 1'
                run %w[git add file1.txt]
                run %w[git commit -m submodule_commit1]
                run %w[git push]
              end

              in_dir 'main_remote' do
                run %w[git init --bare --initial-branch=main]
              end

              in_dir 'main_work_tree' do
                run %w[git clone ../main_remote .]
                run %w[git commit --allow-empty -m commit_1]
                run %w[git push]
                run %w[git -c protocol.file.allow=always submodule add ../submodule_remote submodule_path]
                status_output_to_ruby_string
              end
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid 0e50eae212c35f4264fc20cbe863deafafd0c2f1\u0000" \
              "# branch.head main\u0000" \
              "# branch.upstream origin/main\u0000" \
              "# branch.ab +0 -0\u0000" \
              '1 A. N... 000000 100644 100644 0000000000000000000000000000000000000000 ' \
              "ce19bdf814b7cf06270e885a4ad44b3a1d8adaf4 .gitmodules\u0000" \
              '1 A. S... 000000 160000 160000 0000000000000000000000000000000000000000 ' \
              "2ec065612b9caeaaa54b1e425c18aa3801bf4eef submodule_path\u0000"
          end

          let(:expected_attributes) do
            {
              commit_changed?: false,
              tracked_changes?: false,
              untracked_changes?: false
            }
          end

          it { is_expected.to have_attributes(submodule_status: having_attributes(expected_attributes)) }
        end

        context 'when the submodule commit has changed' do
          subject { report.entries.find { |e| e.path == 'submodule_path' } }

          # :nocov: not run in the test suite
          def reproduce_data
            in_temp_dir do
              submodule_commit1 = nil

              in_dir 'submodule_remote' do
                run %w[git init --bare --initial-branch=main]
              end

              in_dir 'submodule_work_tree' do
                run %w[git clone ../submodule_remote .]
                File.write 'file1.txt', 'Submodule file 1'
                run %w[git add file1.txt]
                run %w[git commit -m submodule_commit1]
                submodule_commit1 = run(%w[git rev-parse HEAD]).stdout.chomp
                run %w[git push]
                File.write 'file1.txt', 'Submodule file 1 with changes'
                run %w[git add file1.txt]
                run %w[git commit -m submodule_commit_2]
                run %w[git push]
              end

              in_dir 'main_remote' do
                run %w[git init --bare --initial-branch=main]
              end

              in_dir 'main_work_tree' do
                run %w[git clone ../main_remote .]
                run %w[git commit --allow-empty -m commit_1]
                run %w[git push]
                run %w[git -c protocol.file.allow=always submodule add ../submodule_remote submodule_path]
                run %w[git add .]
                run %w[git commit -m commit_2]
                run %w[git push]

                in_dir 'submodule_path' do
                  run ['git', 'checkout', submodule_commit1]
                end

                status_output_to_ruby_string
              end
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid a6fc32beefe6985674fbd71ff09e0cca5bd386b9\u0000" \
              "# branch.head main\u0000" \
              "# branch.upstream origin/main\u0000" \
              "# branch.ab +0 -0\u0000" \
              '1 .M SC.. 160000 160000 160000 2b38c34477836bf14f428f786f0e639240e27c29 ' \
              "2b38c34477836bf14f428f786f0e639240e27c29 submodule_path\u0000"
          end

          let(:expected_attributes) do
            {
              commit_changed?: true,
              tracked_changes?: false,
              untracked_changes?: false
            }
          end

          it { is_expected.to have_attributes(submodule_status: having_attributes(expected_attributes)) }
        end

        context 'when the submodule has tracked changes' do
          subject { report.entries.find { |e| e.path == 'submodule_path' } }

          # :nocov: not run in the test suite
          def reproduce_data
            in_temp_dir do
              in_dir 'submodule_remote' do
                run %w[git init --bare --initial-branch=main]
              end

              in_dir 'submodule_work_tree' do
                run %w[git clone ../submodule_remote .]
                File.write 'file1.txt', 'Submodule file 1'
                run %w[git add file1.txt]
                run %w[git commit -m submodule_commit1]
                run %w[git push]
                File.write 'file1.txt', 'Submodule file 1 with changes'
                run %w[git add file1.txt]
                run %w[git commit -m submodule_commit_2]
                run %w[git push]
              end

              in_dir 'main_remote' do
                run %w[git init --bare --initial-branch=main]
              end

              in_dir 'main_work_tree' do
                run %w[git clone ../main_remote .]
                run %w[git commit --allow-empty -m commit_1]
                run %w[git push]
                run %w[git -c protocol.file.allow=always submodule add ../submodule_remote submodule_path]
                run %w[git add .]
                run %w[git commit -m commit_2]
                run %w[git push]

                in_dir 'submodule_path' do
                  File.write('file1.txt', 'Submodule file 1 with even more changes')
                end

                status_output_to_ruby_string
              end
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid ec0e5574529ecede47be2a3938b4f243f13b8696\u0000" \
              "# branch.head main\u0000" \
              "# branch.upstream origin/main\u0000" \
              "# branch.ab +0 -0\u0000" \
              '1 .M S.M. 160000 160000 160000 e4a794fc9241190515b73b75d44f6a9314b0f364 ' \
              "e4a794fc9241190515b73b75d44f6a9314b0f364 submodule_path\u0000"
          end

          let(:expected_attributes) do
            {
              commit_changed?: false,
              tracked_changes?: true,
              untracked_changes?: false
            }
          end

          it { is_expected.to have_attributes(submodule_status: having_attributes(expected_attributes)) }
        end

        context 'when the submodule has untracked changes' do
          subject { report.entries.find { |e| e.path == 'submodule_path' } }

          # :nocov: not run in the test suite
          def reproduce_data
            in_temp_dir do
              in_dir 'submodule_remote' do
                run %w[git init --bare --initial-branch=main]
              end

              in_dir 'submodule_work_tree' do
                run %w[git clone ../submodule_remote .]
                File.write 'file1.txt', 'Submodule file 1'
                run %w[git add file1.txt]
                run %w[git commit -m submodule_commit1]
                run %w[git push]
                File.write 'file1.txt', 'Submodule file 1 with changes'
                run %w[git add file1.txt]
                run %w[git commit -m submodule_commit_2]
                run %w[git push]
              end

              in_dir 'main_remote' do
                run %w[git init --bare --initial-branch=main]
              end

              in_dir 'main_work_tree' do
                run %w[git clone ../main_remote .]
                run %w[git commit --allow-empty -m commit_1]
                run %w[git push]
                run %w[git -c protocol.file.allow=always submodule add ../submodule_remote submodule_path]
                run %w[git add .]
                run %w[git commit -m commit_2]
                run %w[git push]

                in_dir 'submodule_path' do
                  File.write('untracked_file.txt', 'Submodule untracked file')
                end

                status_output_to_ruby_string
              end
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid 11b5eebcacdb6b06f421ed7192a1682c58bbaea7\u0000" \
              "# branch.head main\u0000" \
              "# branch.upstream origin/main\u0000" \
              "# branch.ab +0 -0\u0000" \
              '1 .M S..U 160000 160000 160000 b3b5b039edce740e36694e2a7c3583a28f27b91f ' \
              "b3b5b039edce740e36694e2a7c3583a28f27b91f submodule_path\u0000"
          end

          let(:expected_attributes) do
            {
              commit_changed?: false,
              tracked_changes?: false,
              untracked_changes?: true
            }
          end

          it { is_expected.to have_attributes(submodule_status: having_attributes(expected_attributes)) }
        end
      end
    end
  end
end
