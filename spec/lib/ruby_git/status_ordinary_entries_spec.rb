# frozen_string_literal: true

require 'ruby_git/status'

RSpec.describe RubyGit::Status do
  describe '.parse' do
    let(:report) { described_class.parse(data) }

    describe 'ordinary change entries' do
      subject { report.entries.first }
      let(:entry_class) { RubyGit::Status::OrdinaryEntry }

      describe 'attributes' do
        subject { report.entries.first }

        let(:data) do
          '1 AM N... 000000 100644 100755 1111111111111111111111111111111111111111 ' \
            "2222222222222222222222222222222222222222 file1.txt\u0000"
        end

        let(:expected_attributes) do
          {
            index_status: :added,
            worktree_status: :modified,
            head_mode: 0o000000,
            index_mode: 0o100644,
            worktree_mode: 0o100755,
            head_sha: '1111111111111111111111111111111111111111',
            index_sha: '2222222222222222222222222222222222222222',
            path: 'file1.txt'
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
              File.write 'file1.txt', 'Modified'
              status_output_to_ruby_string
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid (initial)\u0000" \
              "# branch.head main\u0000" \
              '1 AM N... 000000 100644 100644 0000000000000000000000000000000000000000 ' \
              "49351eb5b7e355128f8f569d5b3355c3e2a51d4b file1.txt\u0000"
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
              File.delete 'file1.txt'
              # make a symbolic link named file1.txt
              File.symlink File::NULL, 'file1.txt'
              status_output_to_ruby_string
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid (initial)\u0000" \
              "# branch.head main\u0000" \
              '1 AT N... 000000 100644 120000 0000000000000000000000000000000000000000 ' \
              "49351eb5b7e355128f8f569d5b3355c3e2a51d4b file1.txt\u0000"
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
              File.delete 'file1.txt'
              status_output_to_ruby_string
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid (initial)\u0000" \
              "# branch.head main\u0000" \
              '1 AD N... 000000 100644 000000 0000000000000000000000000000000000000000 ' \
              "49351eb5b7e355128f8f569d5b3355c3e2a51d4b file1.txt\u0000"
          end

          it { is_expected.to be_a(entry_class) }
          it { is_expected.to have_attributes(worktree_status: :deleted) }
        end
      end

      describe 'index modifications' do
        context 'when unmodified in the index' do
          # :nocov: not run in the test suite
          def reproduce_data
            in_temp_dir do
              run %w[git init --initial-branch=main]
              File.write 'file1.txt', 'File 1'
              run %w[git add file1.txt]
              run %w[git commit -m commit_1]
              File.write 'file1.txt', 'File 1 with modifications'
              status_output_to_ruby_string
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid 3d5bb9892d7e69d3e7efa59ccb6504925ad27495\u0000" \
              "# branch.head main\u0000" \
              '1 .M N... 100644 100644 100644 49351eb5b7e355128f8f569d5b3355c3e2a51d4b ' \
              "49351eb5b7e355128f8f569d5b3355c3e2a51d4b file1.txt\u0000"
          end

          it { is_expected.to be_a(entry_class) }
          it { is_expected.to have_attributes(index_status: :unmodified) }
        end

        context 'when modified in the index' do
          # :nocov: not run in the test suite
          def reproduce_data
            in_temp_dir do
              run %w[git init --initial-branch=main]
              File.write 'file1.txt', 'File 1'
              run %w[git add file1.txt]
              run %w[git commit -m commit_1]
              File.write 'file1.txt', 'File 1 with changes'
              run %w[git add file1.txt]
              status_output_to_ruby_string
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid 8d222d17b524c178b5025ab8ba1349e6bb44418d\u0000" \
              "# branch.head main\u0000" \
              '1 M. N... 100644 100644 100644 49351eb5b7e355128f8f569d5b3355c3e2a51d4b ' \
              "909c7b1680316ff5278d0eaa3ba612cf1f6c11d5 file1.txt\u0000"
          end

          it { is_expected.to be_a(entry_class) }
          it { is_expected.to have_attributes(index_status: :modified) }
        end

        context 'when the type is changed in the index' do
          # :nocov: not run in the test suite
          def reproduce_data
            in_temp_dir do
              run %w[git init --initial-branch=main]
              File.write 'file1.txt', 'File 1'
              run %w[git add file1.txt]
              run %w[git commit -m commit_1]
              File.delete 'file1.txt'
              # make a symbolic link named file1.txt
              File.symlink File::NULL, 'file1.txt'
              run %w[git add file1.txt]
              status_output_to_ruby_string
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid ec02678d6b5115fbec5a4c67c13efdd74896f76e\u0000" \
              "# branch.head main\u0000" \
              '1 T. N... 100644 120000 120000 49351eb5b7e355128f8f569d5b3355c3e2a51d4b ' \
              "dc1dc0cde0f7dff7b7f7c9347fff75936d705cb8 file1.txt\u0000"
          end

          it { is_expected.to be_a(entry_class) }
          it { is_expected.to have_attributes(index_status: :type_changed) }
        end

        context 'when added to the index' do
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

          it { is_expected.to be_a(entry_class) }
          it { is_expected.to have_attributes(index_status: :added) }
        end

        context 'when deleted from the index' do
          # :nocov: not run in the test suite
          def reproduce_data
            in_temp_dir do
              run %w[git init --initial-branch=main]
              File.write 'file1.txt', 'File 1'
              run %w[git add file1.txt]
              run %w[git commit -m commit_1]
              run %w[git rm file1.txt]
              status_output_to_ruby_string
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid 570568217d8ddd5e0b5521c047ad201d309f4d9a\u0000" \
              "# branch.head main\u0000" \
              '1 D. N... 100644 000000 000000 49351eb5b7e355128f8f569d5b3355c3e2a51d4b ' \
              "0000000000000000000000000000000000000000 file1.txt\u0000"
          end

          it { is_expected.to be_a(entry_class) }
          it { is_expected.to have_attributes(index_status: :deleted) }
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

      describe 'octal file modes' do
        # Modes are reported in: HEAD, index, worktree
        # Mode values:
        # * 100644: Non-executable file
        # * 100755: Executable file
        # * 120000: Symbolic link
        # * 160000: Submodule
        #
        context 'in the worktree' do
          context 'with a non-executable file' do
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

              # pbcopy(reproduce_data)
              "# branch.oid (initial)\u0000" \
                "# branch.head main\u0000" \
                '1 A. N... 000000 100644 100644 0000000000000000000000000000000000000000 ' \
                "49351eb5b7e355128f8f569d5b3355c3e2a51d4b file1.txt\u0000"
            end

            it { is_expected.to be_a(entry_class) }
            it { is_expected.to have_attributes(worktree_mode: 0o100644) }
          end

          context 'with an executable file' do
            # :nocov: not run in the test suite
            def reproduce_data
              in_temp_dir do
                run %w[git init --initial-branch=main]
                File.write 'file1.sh', '#!/bin/sh'
                File.chmod 0o755, 'file1.sh'
                run %w[git add file1.sh]
                status_output_to_ruby_string
              end
            end
            # :nocov:

            let(:data) do
              # pbcopy(reproduce_data)

              "# branch.oid (initial)\u0000" \
                "# branch.head main\u0000" \
                '1 A. N... 000000 100755 100755 0000000000000000000000000000000000000000 ' \
                "96b4b06ad41630359f54d12db5d43eb52e076ed8 file1.sh\u0000"
            end

            it { is_expected.to be_a(entry_class) }
            it { is_expected.to have_attributes(worktree_mode: 0o100755) }
          end

          context 'with a symbolic link' do
            # :nocov: not run in the test suite
            def reproduce_data
              in_temp_dir do
                run %w[git init --initial-branch=main]
                File.symlink File::NULL, 'file1.txt'
                run %w[git add file1.txt]
                status_output_to_ruby_string
              end
            end
            # :nocov:

            let(:data) do
              # pbcopy(reproduce_data)

              "# branch.oid (initial)\u0000" \
                "# branch.head main\u0000" \
                '1 A. N... 000000 120000 120000 0000000000000000000000000000000000000000 ' \
                "dc1dc0cde0f7dff7b7f7c9347fff75936d705cb8 file1.txt\u0000"
            end

            it { is_expected.to be_a(entry_class) }
            it { is_expected.to have_attributes(worktree_mode: 0o120000) }
          end

          context 'with a submodule' do
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

              "# branch.oid 03ee6a4bed42e4a454134d69305bb8ba825e4368\u0000" \
                "# branch.head main\u0000" \
                "# branch.upstream origin/main\u0000" \
                "# branch.ab +0 -0\u0000" \
                '1 A. N... 000000 100644 100644 0000000000000000000000000000000000000000 ' \
                "ce19bdf814b7cf06270e885a4ad44b3a1d8adaf4 .gitmodules\u0000" \
                '1 A. S... 000000 160000 160000 0000000000000000000000000000000000000000 ' \
                "86be7f47dc11f403072d52c558b9924a89e6cd1b submodule_path\u0000"
            end

            it { is_expected.to be_a(entry_class) }
            it { is_expected.to have_attributes(worktree_mode: 0o160000) }
          end
        end

        context 'in the index' do
          context 'with a non-executable file' do
            # :nocov: not run in the test suite
            def reproduce_data
              in_temp_dir do
                run %w[git init --initial-branch=main]
                File.write 'file1.txt', 'File 1'
                run %w[git add file1.txt]
                File.delete 'file1.txt'
                status_output_to_ruby_string
              end
            end
            # :nocov:

            let(:data) do
              # pbcopy(reproduce_data)

              "# branch.oid (initial)\u0000" \
                "# branch.head main\u0000" \
                '1 AD N... 000000 100644 000000 0000000000000000000000000000000000000000 ' \
                "49351eb5b7e355128f8f569d5b3355c3e2a51d4b file1.txt\u0000"
            end

            it { is_expected.to be_a(entry_class) }
            it { is_expected.to have_attributes(index_mode: 0o100644) }
          end

          context 'with an executable file' do
            # :nocov: not run in the test suite
            def reproduce_data
              in_temp_dir do
                run %w[git init --initial-branch=main]
                File.write 'file1.sh', '#!/bin/sh'
                File.chmod 0o755, 'file1.sh'
                run %w[git add file1.sh]
                File.delete 'file1.sh'
                status_output_to_ruby_string
              end
            end
            # :nocov:

            let(:data) do
              # pbcopy(reproduce_data)

              "# branch.oid (initial)\u0000" \
                "# branch.head main\u0000" \
                '1 AD N... 000000 100755 000000 0000000000000000000000000000000000000000 ' \
                "96b4b06ad41630359f54d12db5d43eb52e076ed8 file1.sh\u0000"
            end

            it { is_expected.to be_a(entry_class) }
            it { is_expected.to have_attributes(index_mode: 0o100755) }
          end

          context 'with a symbolic link' do
            # :nocov: not run in the test suite
            def reproduce_data
              in_temp_dir do
                run %w[git init --initial-branch=main]
                File.symlink File::NULL, 'file1.txt'
                run %w[git add file1.txt]
                File.delete 'file1.txt'
                status_output_to_ruby_string
              end
            end
            # :nocov:

            let(:data) do
              # pbcopy(reproduce_data)

              "# branch.oid (initial)\u0000" \
                "# branch.head main\u0000" \
                '1 AD N... 000000 120000 000000 0000000000000000000000000000000000000000 ' \
                "dc1dc0cde0f7dff7b7f7c9347fff75936d705cb8 file1.txt\u0000"
            end

            it { is_expected.to be_a(entry_class) }
            it { is_expected.to have_attributes(index_mode: 0o120000) }
          end

          context 'with a submodule' do
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
                  FileUtils.rm_rf 'submodule_path'
                  status_output_to_ruby_string
                end
              end
            end
            # :nocov:

            let(:data) do
              # pbcopy(reproduce_data)

              "# branch.oid 1d2eaac76fbfed0a5f8120e75b4f35352d0e4ddb\u0000" \
                "# branch.head main\u0000" \
                "# branch.upstream origin/main\u0000" \
                "# branch.ab +0 -0\u0000" \
                '1 A. N... 000000 100644 100644 0000000000000000000000000000000000000000 ' \
                "ce19bdf814b7cf06270e885a4ad44b3a1d8adaf4 .gitmodules\u0000" \
                '1 AD S... 000000 160000 000000 0000000000000000000000000000000000000000 ' \
                "68d1dcf7188961c5e369645f9e686ba0c31617e3 submodule_path\u0000"
            end

            it { is_expected.to be_a(entry_class) }
            it { is_expected.to have_attributes(index_mode: 0o160000) }
          end
        end

        context 'in the HEAD' do
          context 'with a non-executable file' do
            # :nocov: not run in the test suite
            def reproduce_data
              in_temp_dir do
                run %w[git init --initial-branch=main]
                File.write 'file1.txt', 'File 1'
                run %w[git add file1.txt]
                run %w[git commit -m commit_1]
                run %w[git rm file1.txt]
                status_output_to_ruby_string
              end
            end
            # :nocov:

            let(:data) do
              # pbcopy(reproduce_data)

              "# branch.oid 5ba1bf5fa9a345ad2f707107ee6ab0f9f9607033\u0000" \
                "# branch.head main\u0000" \
                '1 D. N... 100644 000000 000000 49351eb5b7e355128f8f569d5b3355c3e2a51d4b ' \
                "0000000000000000000000000000000000000000 file1.txt\u0000"
            end

            it { is_expected.to be_a(entry_class) }
            it { is_expected.to have_attributes(head_mode: 0o100644) }
          end

          context 'with an executable file' do
            # :nocov: not run in the test suite
            def reproduce_data
              in_temp_dir do
                run %w[git init --initial-branch=main]
                File.write 'file1.sh', '#!/bin/sh'
                File.chmod 0o755, 'file1.sh'
                run %w[git add file1.sh]
                run %w[git commit -m commit_1]
                run %w[git rm file1.sh]
                status_output_to_ruby_string
              end
            end
            # :nocov:

            let(:data) do
              # pbcopy(reproduce_data)

              "# branch.oid f9309a10ca0e42b0b24ba15ba1455bf6265d6e8b\u0000" \
                "# branch.head main\u0000" \
                '1 D. N... 100755 000000 000000 96b4b06ad41630359f54d12db5d43eb52e076ed8 ' \
                "0000000000000000000000000000000000000000 file1.sh\u0000"
            end

            it { is_expected.to be_a(entry_class) }
            it { is_expected.to have_attributes(head_mode: 0o100755) }
          end

          context 'with a symbolic link' do
            # :nocov: not run in the test suite
            def reproduce_data
              in_temp_dir do
                run %w[git init --initial-branch=main]
                File.symlink File::NULL, 'file1.txt'
                run %w[git add file1.txt]
                run %w[git commit -m commit_1]
                run %w[git rm file1.txt]
                status_output_to_ruby_string
              end
            end
            # :nocov:

            let(:data) do
              # pbcopy(reproduce_data)

              "# branch.oid 34a48c754e12c18cd2af3cc80d7b4a361d6f14bd\u0000" \
                "# branch.head main\u0000" \
                '1 D. N... 120000 000000 000000 dc1dc0cde0f7dff7b7f7c9347fff75936d705cb8 ' \
                "0000000000000000000000000000000000000000 file1.txt\u0000"
            end

            it { is_expected.to be_a(entry_class) }
            it { is_expected.to have_attributes(head_mode: 0o120000) }
          end

          context 'with a submodule' do
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
                  FileUtils.rm_rf 'submodule_path'
                  run %w[git commit -m commit_2]
                  status_output_to_ruby_string
                end
              end
            end
            # :nocov:

            let(:data) do
              # pbcopy(reproduce_data)

              "# branch.oid 6667eb0762968644d3921b802ca500dec5c768d6\u0000" \
                "# branch.head main\u0000" \
                "# branch.upstream origin/main\u0000" \
                "# branch.ab +1 -0\u0000" \
                '1 .D S... 160000 160000 000000 67702da4950eeb40f79e56774145b0bfd281f977 ' \
                "67702da4950eeb40f79e56774145b0bfd281f977 submodule_path\u0000"
            end

            it { is_expected.to be_a(entry_class) }
            it { is_expected.to have_attributes(head_mode: 0o160000) }
          end
        end
      end

      describe 'object shas' do
        # Object names (aka their SHA) are reported in: HEAD and index only
        #
        context 'in HEAD' do
          # :nocov: not run in the test suite
          def reproduce_data
            in_temp_dir do
              run %w[git init --initial-branch=main]
              File.write 'file1.txt', 'File 1'
              run %w[git add file1.txt]
              run %w[git commit -m commit_1]
              run %w[git rm file1.txt]
              status_output_to_ruby_string
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid a808da6da3a2bf82c2978af3fcd050f6d9f434d8\u0000" \
              "# branch.head main\u0000" \
              '1 D. N... 100644 000000 000000 49351eb5b7e355128f8f569d5b3355c3e2a51d4b ' \
              "0000000000000000000000000000000000000000 file1.txt\u0000"
          end

          it { is_expected.to be_a(entry_class) }
          it { is_expected.to have_attributes(head_sha: '49351eb5b7e355128f8f569d5b3355c3e2a51d4b') }
        end

        context 'in the index' do
          # :nocov: not run in the test suite
          def reproduce_data
            in_temp_dir do
              run %w[git init --initial-branch=main]
              File.write 'file1.txt', 'File 1'
              run %w[git add file1.txt]
              File.delete 'file1.txt'
              status_output_to_ruby_string
            end
          end
          # :nocov:

          let(:data) do
            # pbcopy(reproduce_data)

            "# branch.oid (initial)\u0000" \
              "# branch.head main\u0000" \
              '1 AD N... 000000 100644 000000 0000000000000000000000000000000000000000 ' \
              "49351eb5b7e355128f8f569d5b3355c3e2a51d4b file1.txt\u0000"
          end

          it { is_expected.to be_a(entry_class) }
          it { is_expected.to have_attributes(index_sha: '49351eb5b7e355128f8f569d5b3355c3e2a51d4b') }
        end
      end
    end
  end
end
