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
        let(:reproduction_recipe) { <<~RECIPE }
          . reset-test
          git init --initial-branch=main
          ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
        RECIPE

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
            ahead: nil,
            behind: nil
          }
        end

        it { is_expected.to have_attributes(expected_attributes) }
      end

      context 'a branch with no upstream' do
        let(:reproduction_recipe) { <<~RECIPE }
          . reset-test
          git init --initial-branch=main
          git commit --allow-empty -m "Commit 1"
          ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
        RECIPE
        let(:data) do
          "# branch.oid a58176a9d80e87c948b3b90d4eeaaab454d571da\u0000" \
            "# branch.head main\u0000"
        end

        let(:expected_attributes) do
          {
            name: 'main',
            oid: 'a58176a9d80e87c948b3b90d4eeaaab454d571da',
            detached?: false,
            upstream: nil,
            ahead: nil,
            behind: nil
          }
        end

        it { is_expected.to have_attributes(expected_attributes) }
      end

      context 'with an empty upstream' do
        let(:reproduction_recipe) { <<~RECIPE }
          . reset-test
          mkdir remote work_tree
          cd remote
          git init --bare --initial-branch=main
          cd ../work_tree
          git clone ../remote .
          ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
        RECIPE

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
            ahead: nil,
            behind: nil
          }
        end

        it { is_expected.to have_attributes(expected_attributes) }
      end

      context 'with an non-empty upstream' do
        let(:reproduction_recipe) { <<~RECIPE }
          . reset-test
          mkdir remote work_tree
          cd remote
          git init --bare --initial-branch=main
          cd ../work_tree
          git clone ../remote .
          git commit --allow-empty -m "Commit 1"
          git push -u origin main
          ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
        RECIPE

        let(:data) do
          "# branch.oid cc06f46f323dd9b046610021236fba0fc70ff4b4\u0000" \
            "# branch.head main\u0000" \
            "# branch.upstream origin/main\u0000" \
            "# branch.ab +0 -0\u0000"
        end

        let(:expected_attributes) do
          {
            name: 'main',
            oid: 'cc06f46f323dd9b046610021236fba0fc70ff4b4',
            detached?: false,
            upstream: 'origin/main',
            ahead: 0,
            behind: 0
          }
        end

        it { is_expected.to have_attributes(expected_attributes) }
      end

      context 'with non-zero ahead and behind' do
        let(:reproduction_recipe) { <<~RECIPE }
          . reset-test
          mkdir remote work_tree
          cd remote
          git init --bare --initial-branch=main
          cd ../work_tree
          git clone ../remote .
          git commit --allow-empty -m "Commit 1"
          git commit --allow-empty -m "Commit 2"
          git push -u origin main
          git reset HEAD~1
          git commit --allow-empty -m "Commit 3"
          git commit --allow-empty -m "Commit 4"
          ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
        RECIPE

        let(:data) do
          "# branch.oid 67ee4ea16aae3b3e4f0ee398b272adb0abd099da\u0000" \
            "# branch.head main\u0000" \
            "# branch.upstream origin/main\u0000" \
            "# branch.ab +2 -1\u0000"
        end

        let(:expected_attributes) do
          {
            name: 'main',
            oid: '67ee4ea16aae3b3e4f0ee398b272adb0abd099da',
            detached?: false,
            upstream: 'origin/main',
            ahead: 2,
            behind: 1
          }
        end

        it { is_expected.to have_attributes(expected_attributes) }
      end

      context 'with detached HEAD' do
        let(:reproduction_recipe) { <<~RECIPE }
          . reset-test
          git init --initial-branch=main
          git commit --allow-empty -m "Initial commit"
          git checkout --detach HEAD
          ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
        RECIPE

        let(:data) do
          "# branch.oid f80e4f7291bb10b4e91961f1352187fbf3b44103\u0000" \
            "# branch.head (detached)\u0000"
        end

        let(:expected_attributes) do
          {
            name: nil,
            oid: 'f80e4f7291bb10b4e91961f1352187fbf3b44103',
            detached?: true,
            upstream: nil,
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
        let(:reproduction_recipe) { <<~RECIPE }
          . reset-test
          git init --initial-branch=main
          git commit --allow-empty -m "Initial commit"
          ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
        RECIPE

        let(:data) do
          "# branch.oid aefa3082443e700c415feaefa4ed743e56cc530f\u0000" \
            "# branch.head main\u0000"
        end

        it { is_expected.to have_attributes(count: 0) }
      end

      context 'with more than 3 stashes' do
        let(:reproduction_recipe) { <<~RECIPE }
          . reset-test
          git init --initial-branch=main
          git commit --allow-empty -m "Initial commit"
          echo "stash 1" > file.txt && git stash push -u -m "Stash 1"
          echo "stash 2" > file.txt && git stash push -u -m "Stash 2"
          echo "stash 3" > file.txt && git stash push -u -m "Stash 3"
          ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
        RECIPE

        let(:data) do
          "# branch.oid 42e76bc638e2afba3625bd6819aaadc28a26876b\u0000" \
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

    # . = unmodified
    # M = modified
    # T = file type changed (regular file, symbolic link or submodule)
    # A = added
    # D = deleted
    # R = renamed
    # C = copied (if config option status.renames is set to "copies")
    # U = updated but unmerged

    # . [.AMD] #
    # M [.MTD] #
    # T [.MTD] #
    # A [.MTD] #
    # D [.]    # index is deleted, working tree file is treated as a separate untracked entry if present
    # R [.MTD] #
    # C [.MTD] #

    # [.MTARC] .
    # [.MTARC] M
    # [.MTARC] T
    # [.MTARC] D

    describe 'ordinary change entries' do
      subject { report.entries.first }

      describe 'different work tree modifications' do
        context 'when unmodified in the work tree' do
          subject { report.entries.first }

          let(:reproduction_recipe) { <<~RECIPE }
            . reset-test
            git init --initial-branch=main
            echo "File 1" > file1.txt
            git add file1.txt
            ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
          RECIPE

          let(:data) do
            "# branch.oid (initial)\u0000# branch.head main\u0000" \
              '1 A. N... 000000 100644 100644 0000000000000000000000000000000000000000 ' \
              "50fcd26d6ce3000f9d5f12904e80eccdc5685dd1 file1.txt\u0000"
          end

          it { is_expected.to have_attributes(worktree_status: :unmodified) }
        end

        context 'when modified in the work tree' do
          let(:reproduction_recipe) { <<~RECIPE }
            . reset-test
            git init --initial-branch=main
            echo "File 1" > file1.txt
            git add file1.txt
            git commit -m "Initial commit"
            echo "Modified" > file1.txt
            ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
          RECIPE

          let(:data) do
            "# branch.oid 7b8e26e48f59feec46c77cea35173620e6851ef0\u0000" \
              "# branch.head main\u0000" \
              '1 .M N... 100644 100644 100644 50fcd26d6ce3000f9d5f12904e80eccdc5685dd1 ' \
              "50fcd26d6ce3000f9d5f12904e80eccdc5685dd1 file1.txt\u0000"
          end

          it { is_expected.to have_attributes(worktree_status: :modified) }
        end

        context 'when the type is changed in the work tree' do
          let(:reproduction_recipe) { <<~RECIPE }
            . reset-test
            git init --initial-branch=main
            echo "File 1" > file1.txt
            git add file1.txt
            rm file1.txt
            # make a symbolic link named file1.txt
            ln -s /dev/null file1.txt
            ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
          RECIPE

          let(:data) do
            "# branch.oid (initial)\u0000" \
              "# branch.head main\u0000" \
              '1 AT N... 000000 100644 120000 0000000000000000000000000000000000000000 ' \
              "50fcd26d6ce3000f9d5f12904e80eccdc5685dd1 file1.txt\u0000"
          end

          it { is_expected.to have_attributes(worktree_status: :type_changed) }
        end

        context 'when deleted from the work tree' do
          let(:reproduction_recipe) { <<~RECIPE }
            . reset-test
            git init --initial-branch=main
            echo "File 1" > file1.txt
            git add file1.txt
            rm file1.txt
            ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
          RECIPE

          let(:data) do
            "# branch.oid (initial)\u0000" \
              "# branch.head main\u0000" \
              '1 AD N... 000000 100644 000000 0000000000000000000000000000000000000000 ' \
              "50fcd26d6ce3000f9d5f12904e80eccdc5685dd1 file1.txt\u0000"
          end

          it { is_expected.to have_attributes(worktree_status: :deleted) }
        end
      end

      describe 'different index modifications' do
        context 'when unmodified in the index' do
          let(:reproduction_recipe) { <<~RECIPE }
            . reset-test
            git init --initial-branch=main
            echo "File 1" > file1.txt
            git add file1.txt
            git commit -m "Commit 1"
            echo "File 1 with changes" > file1.txt
            ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
          RECIPE

          let(:data) do
            "# branch.oid c3d5852e883bd95dcf8df6112ed4caec3f50f907\u0000" \
              "# branch.head main\u0000" \
              '1 .M N... 100644 100644 100644 50fcd26d6ce3000f9d5f12904e80eccdc5685dd1 ' \
              "50fcd26d6ce3000f9d5f12904e80eccdc5685dd1 file1.txt\u0000"
          end

          it { is_expected.to have_attributes(staging_status: :unmodified) }
        end

        context 'when modified in the index' do
          let(:reproduction_recipe) { <<~RECIPE }
            . reset-test
            git init --initial-branch=main
            echo "File 1" > file1.txt
            git add file1.txt
            git commit -m "Commit 1"
            echo "File 1 with changes" > file1.txt
            git add file1.txt
            ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
          RECIPE

          let(:data) do
            "# branch.oid 5e916fe5cd7bd73f796568524482c36831e6c261\u0000" \
              "# branch.head main\u0000" \
              '1 M. N... 100644 100644 100644 50fcd26d6ce3000f9d5f12904e80eccdc5685dd1 ' \
              "3d33c0759b924973fc1cb713c9f63514af5f747a file1.txt\u0000"
          end

          it { is_expected.to have_attributes(staging_status: :modified) }
        end

        context 'when the type is changed in the index' do
          let(:reproduction_recipe) { <<~RECIPE }
            . reset-test
            git init --initial-branch=main
            echo "File 1" > file1.txt
            git add file1.txt
            git commit -m "Commit 1"
            rm file1.txt
            # make a symbolic link named file1.txt
            ln -s /dev/null file1.txt
            git add file1.txt
            ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
          RECIPE

          let(:data) do
            "# branch.oid 145947abe0bee804e248054e80ef7403f4ac8473\u0000" \
              "# branch.head main\u0000" \
              '1 T. N... 100644 120000 120000 50fcd26d6ce3000f9d5f12904e80eccdc5685dd1 ' \
              "dc1dc0cde0f7dff7b7f7c9347fff75936d705cb8 file1.txt\u0000"
          end

          it { is_expected.to have_attributes(staging_status: :type_changed) }
        end

        context 'when added to the index' do
          let(:reproduction_recipe) { <<~RECIPE }
            . reset-test
            git init --initial-branch=main
            echo "File 1" > file1.txt
            git add file1.txt
            ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
          RECIPE

          let(:data) do
            "# branch.oid (initial)\u0000" \
              "# branch.head main\u0000" \
              '1 A. N... 000000 100644 100644 0000000000000000000000000000000000000000 ' \
              "50fcd26d6ce3000f9d5f12904e80eccdc5685dd1 file1.txt\u0000"
          end

          it { is_expected.to have_attributes(staging_status: :added) }
        end

        context 'when deleted from the index' do
          let(:reproduction_recipe) { <<~RECIPE }
            . reset-test
            git init --initial-branch=main
            echo "File 1" > file1.txt
            git add file1.txt
            git commit -m "Commit 1"
            git rm file1.txt
            ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
          RECIPE

          let(:data) do
            "# branch.oid 66e0097c21c504ce3928c72ed0760ede6683e190\u0000" \
              "# branch.head main\u0000" \
              '1 D. N... 100644 000000 000000 50fcd26d6ce3000f9d5f12904e80eccdc5685dd1 ' \
              "0000000000000000000000000000000000000000 file1.txt\u0000"
          end

          it { is_expected.to have_attributes(staging_status: :deleted) }
        end
      end

      describe 'submodule modifications' do
        subject { report.entries.first.submodule_status }

        context 'when the entry is not a submodule' do
          let(:reproduction_recipe) { <<~RECIPE }
            . reset-test
            git init --initial-branch=main
            echo "File 1" > file1.txt
            git add file1.txt
            ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
          RECIPE

          let(:data) do
            "# branch.oid (initial)\u0000" \
              "# branch.head main\u0000" \
              '1 A. N... 000000 100644 100644 0000000000000000000000000000000000000000 ' \
              "50fcd26d6ce3000f9d5f12904e80eccdc5685dd1 file1.txt\u0000"
          end

          it { is_expected.to be_nil }
        end

        context 'when the entry is a submodule with no changes' do
          subject { report.entries.find { |e| e.path == 'submodule_path' } }

          let(:reproduction_recipe) { <<~RECIPE }
            . reset-test
            mkdir main_remote main_work_tree submodule_remote submodule_work_tree
            cd submodule_remote
            git init --bare --initial-branch=main
            cd ../submodule_work_tree
            git clone ../submodule_remote .
            echo "Submodule file 1" > file1.txt
            git add file1.txt
            git commit -m "Submodule commit 1"
            git push

            cd ../main_remote
            git init --bare --initial-branch=main
            cd ../main_work_tree
            git clone ../main_remote .
            git commit --allow-empty -m "Initial commit"
            git push
            git -c protocol.file.allow=always submodule add ../submodule_remote submodule_path

            ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
          RECIPE

          let(:data) do
            "# branch.oid d3ac0299eea86d96e5ab22db13762743c1a945ac\u0000" \
              "# branch.head main\u0000" \
              "# branch.upstream origin/main\u0000" \
              "# branch.ab +0 -0\u0000" \
              '1 A. N... 000000 100644 100644 0000000000000000000000000000000000000000 ' \
              "ce19bdf814b7cf06270e885a4ad44b3a1d8adaf4 .gitmodules\u0000" \
              '1 A. S... 000000 160000 160000 0000000000000000000000000000000000000000 ' \
              "1906a7d49739a4d305eab4db74ae98c3e4810b84 submodule_path\u0000"
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

          let(:reproduction_recipe) { <<~RECIPE }
            . reset-test
            mkdir main_remote main_work_tree submodule_remote submodule_work_tree

            cd submodule_remote
            git init --bare --initial-branch=main
            cd ../submodule_work_tree
            git clone ../submodule_remote .
            echo "Submodule file 1" > file1.txt
            git add file1.txt
            git commit -m "Submodule commit 1"
            # Save the current commit to an environment variable
            SUBMODULE_COMMIT_1=$(git rev-parse HEAD)
            echo "Submodule file 1 with changes" > file1.txt
            git add file1.txt
            git commit -m "Submodule commit 2"
            git push

            cd ../main_remote
            git init --bare --initial-branch=main
            cd ../main_work_tree
            git clone ../main_remote .
            git commit --allow-empty -m "Initial commit"
            git push
            git -c protocol.file.allow=always submodule add ../submodule_remote submodule_path

            git add .
            git commit -m "Main commit 1"
            git push

            cd submodule_path
            git checkout $SUBMODULE_COMMIT_1
            cd ..

            ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
          RECIPE

          let(:data) do
            "# branch.oid b08e17e45bae7aa7bb802f29f55a2e0e19120777\u0000" \
              "# branch.head main\u0000" \
              "# branch.upstream origin/main\u0000" \
              "# branch.ab +0 -0\u0000" \
              '1 .M SC.. 160000 160000 160000 cf4f1b74e089382b3e0d69dabd2b2d2441e6e325 ' \
              "cf4f1b74e089382b3e0d69dabd2b2d2441e6e325 submodule_path\u0000"
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

          let(:reproduction_recipe) { <<~RECIPE }
            . reset-test
            mkdir main_remote main_work_tree submodule_remote submodule_work_tree

            cd submodule_remote
            git init --bare --initial-branch=main
            cd ../submodule_work_tree
            git clone ../submodule_remote .
            echo "Submodule file 1" > file1.txt
            git add file1.txt
            git commit -m "Submodule commit 1"
            # Save the current commit to an environment variable
            SUBMODULE_COMMIT_1=$(git rev-parse HEAD)
            echo "Submodule file 1 with changes" > file1.txt
            git add file1.txt
            git commit -m "Submodule commit 2"
            git push

            cd ../main_remote
            git init --bare --initial-branch=main
            cd ../main_work_tree
            git clone ../main_remote .
            git commit --allow-empty -m "Initial commit"
            git push
            git -c protocol.file.allow=always submodule add ../submodule_remote submodule_path

            git add .
            git commit -m "Main commit 1"
            git push

            echo "Submodule file 1 with even more changes" > submodule_path/file1.txt

            ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
          RECIPE

          let(:data) do
            "# branch.oid d31865e59d2440b65965a6f31ce7b3dd87984f50\u0000" \
              "# branch.head main\u0000" \
              "# branch.upstream origin/main\u0000" \
              "# branch.ab +0 -0\u0000" \
              '1 .M S.M. 160000 160000 160000 0d3281c0b17ec9430b14e23953653a73f5fb09ff ' \
              "0d3281c0b17ec9430b14e23953653a73f5fb09ff submodule_path\u0000"
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

          let(:reproduction_recipe) { <<~RECIPE }
            . reset-test
            mkdir main_remote main_work_tree submodule_remote submodule_work_tree

            cd submodule_remote
            git init --bare --initial-branch=main
            cd ../submodule_work_tree
            git clone ../submodule_remote .
            echo "Submodule file 1" > file1.txt
            git add file1.txt
            git commit -m "Submodule commit 1"
            # Save the current commit to an environment variable
            SUBMODULE_COMMIT_1=$(git rev-parse HEAD)
            echo "Submodule file 1 with changes" > file1.txt
            git add file1.txt
            git commit -m "Submodule commit 2"
            git push

            cd ../main_remote
            git init --bare --initial-branch=main
            cd ../main_work_tree
            git clone ../main_remote .
            git commit --allow-empty -m "Initial commit"
            git push
            git -c protocol.file.allow=always submodule add ../submodule_remote submodule_path

            git add .
            git commit -m "Main commit 1"
            git push

            echo "Submodule untracked file" > submodule_path/untracked_file.txt

            ruby -e 'puts `git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z`.inspect'
          RECIPE

          let(:data) do
            "# branch.oid 14226424e5b185466e786356e72f438ff6cc9186\u0000" \
              "# branch.head main\u0000" \
              "# branch.upstream origin/main\u0000" \
              "# branch.ab +0 -0\u0000" \
              '1 .M S..U 160000 160000 160000 15924dee41d6f70e850126a18a010879015cad0e ' \
              "15924dee41d6f70e850126a18a010879015cad0e submodule_path\u0000"
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

      describe 'octal file modes'

      describe 'object names'
    end

    describe 'renamed entries'
    describe 'unmerged entries'
    describe 'untracked entries'

    # context 'with ordinary entries' do
    #   it 'parses submodule entries correctly' do
    #     # To reproduce:
    #     # git init
    #     # git commit --allow-empty -m "Initial commit"
    #     # git submodule add https://github.com/user/repo.git submodule_path
    #     # cd submodule_path && echo "change" > file.txt && git add file.txt
    #     # (This would show submodule status with "S.M.")
    #     submodule_data = "1 .MS.C. 160000 160000 160000 abcdef1234567890 abcdef1234567890 submodule_path\u0000"
    #     result = described_class.parse(submodule_data)

    #     expect(result.entries.size).to eq(1)
    #     entry = result.entries.first
    #     expect(entry).to be_a(RubyGit::Status::OrdinaryEntry)
    #     expect(entry).to have_attributes(
    #       submodule?: true,
    #       submodule_status: 'S.C.'
    #     )
    #   end

    #   it 'parses untracked entries through OrdinaryEntry' do
    #     # To reproduce:
    #     # git init
    #     # git commit --allow-empty -m "Initial commit"
    #     # touch untracked.txt
    #     # (Note: In newer Git versions, untracked files would use the ? prefix,
    #     # but this test is for backward compatibility with git status format)
    #     untracked_data = "1 ?? N... 000000 000000 000000 0000000000000000 0000000000000000 untracked.txt\u0000"
    #     result = described_class.parse(untracked_data)

    #     expect(result.entries.size).to eq(1)
    #     entry = result.entries.first
    #     expect(entry).to be_a(RubyGit::Status::OrdinaryEntry)
    #     expect(entry).to have_attributes(
    #       untracked?: true,
    #       worktree_status: :untracked
    #     )
    #   end

    #   it 'handles unknown status codes' do
    #     # This is a synthetic test case to ensure the parser is resilient to unknown status codes
    #     # Not easily reproducible with regular git commands
    #     unknown_data = "1 XY N... 100644 100644 100644 abcdef1234567890 abcdef1234567890 unknown.txt\u0000"
    #     result = described_class.parse(unknown_data)

    #     expect(result.entries.size).to eq(1)
    #     entry = result.entries.first
    #     expect(entry).to have_attributes(
    #       staging_status: :unknown,
    #       worktree_status: :unknown
    #     )
    #   end
    # end

    # context 'with renamed entries' do
    #   it 'handles renamed entry parsing with standard format' do
    #     renamed_data = "2 R. N... 100644 100644 100644 abcdef1234567890 abcdef1234567890 old_file.txt new_file.txt\0"

    #     result = described_class.parse(renamed_data)
    #     expect(result.entries.size).to eq(1)
    #     expect(result.entries.first).to be_a(RubyGit::Status::RenamedEntry)

    #     expect(result.entries.first).to have_attributes(
    #       path: 'new_file.txt',
    #       original_path: 'old_file.txt',
    #       similarity: 0,
    #       staging_status: :renamed,
    #       worktree_status: :unmodified,
    #       staged?: true,
    #       unstaged?: false
    #     )
    #   end

    #   it 'handles renamed entry with similarity token' do
    #     renamed_data = '2 R. N... 100644 100644 100644 abcdef1234567890 ' \
    #                    "abcdef1234567890 R95 old_file.txt new_file.txt\0"

    #     result = described_class.parse(renamed_data)
    #     expect(result.entries.first.similarity).to eq(95)
    #   end
    # end

    # context 'with unmerged entries' do
    #   let(:unmerged_data) do
    #     "u 1 100644 100644 100644 abcdef1234567890 abcdef1234567890 abcdef1234567890 conflict.txt\0"
    #   end

    #   it 'parses unmerged entries correctly' do
    #     result = described_class.parse(unmerged_data)

    #     expect(result.entries.size).to eq(1)
    #     expect(result.entries.first).to be_a(RubyGit::Status::UnmergedEntry)

    #     entry = result.entries.first
    #     expect(entry).to have_attributes(
    #       path: 'conflict.txt',
    #       conflict_type: :both_added,
    #       worktree_status: :updated_but_unmerged,
    #       staged?: false,
    #       unstaged?: true
    #     )

    #     expect(entry.stage_1).to be_a(Hash)
    #     expect(entry.stage_1[:mode]).to eq('100644')
    #     expect(entry.stage_2).to be_a(Hash)
    #     expect(entry.stage_3).to be_a(Hash)
    #   end

    #   it 'handles missing stages correctly' do
    #     data = 'u 3 0 0000000000000000000000000000000000000000 100644 abcdef1234567890 ' \
    #            "0 0000000000000000000000000000000000000000 file.txt\0"
    #     result = described_class.parse(data)

    #     entry = result.entries.first
    #     expect(entry).to have_attributes(
    #       conflict_type: :added_by_us,
    #       path: 'file.txt'
    #     )
    #     expect(entry.stage_one).to be_nil
    #     expect(entry.stage_two).not_to be_nil
    #     expect(entry.stage_three).to be_nil
    #   end
    # end

    # context 'with ignored entries' do
    #   let(:ignored_data) { "! ignored.txt\u0000" }

    #   it 'parses ignored entries correctly' do
    #     # To reproduce:
    #     # git init
    #     # git commit --allow-empty -m "Initial commit"
    #     # echo "ignored.txt" > .gitignore && git add .gitignore && git commit -m "Add gitignore"
    #     # touch ignored.txt
    #     result = described_class.parse(ignored_data)

    #     expect(result.entries.size).to eq(1)
    #     expect(result.entries.first).to be_a(RubyGit::Status::IgnoredEntry)

    #     entry = result.entries.first
    #     expect(entry).to have_attributes(
    #       path: 'ignored.txt',
    #       worktree_status: :ignored,
    #       staged?: false,
    #       unstaged?: false
    #     )
    #   end
    # end

    # context 'with untracked entries' do
    #   let(:untracked_data) { "? untracked.txt\u0000" }

    #   it 'parses untracked entries correctly' do
    #     # To reproduce:
    #     # git init
    #     # git commit --allow-empty -m "Initial commit"
    #     # touch untracked.txt
    #     result = described_class.parse(untracked_data)

    #     expect(result.entries.size).to eq(1)
    #     expect(result.entries.first).to be_a(RubyGit::Status::UntrackedEntry)

    #     entry = result.entries.first
    #     expect(entry).to have_attributes(
    #       path: 'untracked.txt',
    #       worktree_status: :untracked,
    #       staged?: false,
    #       unstaged?: false
    #     )
    #   end
    # end

    # context 'with a mix of entry types' do
    #   let(:mixed_data) do
    #     [
    #       "# branch.head main\0",
    #       "# stash 2\0",
    #       "1 M. N... 100644 100644 100644 abcdef1234567890 abcdef1234567890 modified.txt\0",
    #       "2 R. N... 100644 100644 100644 abcdef1234567890 abcdef1234567890 R95 old.txt new.txt\0",
    #       "u 2 100644 100644 100644 abcdef abcdef abcdef conflict.txt\0",
    #       "! ignored.txt\0",
    #       "? untracked.txt\0"
    #     ].join
    #   end

    #   it 'parses all entries correctly' do
    #     result = described_class.parse(mixed_data)

    #     expect(result.branch).not_to be_nil
    #     expect(result.stash).not_to be_nil
    #     expect(result.entries.size).to eq(5)

    #     expect(result.entries[0]).to be_a(RubyGit::Status::OrdinaryEntry)
    #     expect(result.entries[1]).to be_a(RubyGit::Status::RenamedEntry)
    #     expect(result.entries[2]).to be_a(RubyGit::Status::UnmergedEntry)
    #     expect(result.entries[3]).to be_a(RubyGit::Status::IgnoredEntry)
    #     expect(result.entries[4]).to be_a(RubyGit::Status::UntrackedEntry)
    #   end
    # end

    # context 'with filtering methods' do
    #   let(:filter_data) do
    #     [
    #       "1 M. N... 100644 100644 100644 abc abc modified_staged.txt\u0000",
    #       "1 .M N... 100644 100644 100644 abc abc modified_unstaged.txt\u0000",
    #       "? untracked.txt\u0000",
    #       "! ignored.txt\u0000",
    #       "u 2 100644 100644 100644 abc abc abc conflict.txt\u0000"
    #     ].join
    #   end

    #   it 'filters entries correctly' do
    #     result = described_class.parse(filter_data)

    #     # Test filtering methods
    #     expect(result.staged.size).to eq(1)
    #     expect(result.staged.first.path).to eq('modified_staged.txt')

    #     expect(result.unstaged.size).to eq(2) # modified_unstaged.txt and conflict.txt
    #     expect(result.unstaged.map(&:path)).to include('modified_unstaged.txt', 'conflict.txt')

    #     expect(result.untracked.size).to eq(1)
    #     expect(result.untracked.first.path).to eq('untracked.txt')

    #     expect(result.ignored.size).to eq(1)
    #     expect(result.ignored.first.path).to eq('ignored.txt')

    #     expect(result.unmerged.size).to eq(1)
    #     expect(result.unmerged.first.path).to eq('conflict.txt')
    #   end

    #   it 'correctly identifies clean repositories' do
    #     result = described_class.parse('')
    #     expect(result.clean?).to be true
    #   end

    #   it 'filters staged and unstaged entries by specific status' do
    #     data = [
    #       "1 M. N... 100644 100644 100644 abc abc modified.txt\u0000",
    #       "1 A. N... 000000 100644 100644 000 abc added.txt\u0000",
    #       "1 .M N... 100644 100644 100644 abc abc unstaged_modified.txt\u0000",
    #       "1 .D N... 100644 000000 000000 abc 000 unstaged_deleted.txt\u0000"
    #     ].join

    #     result = described_class.parse(data)

    #     expect(result.staged(:modified).size).to eq(1)
    #     expect(result.staged(:modified).first.path).to eq('modified.txt')

    #     expect(result.staged(:added).size).to eq(1)
    #     expect(result.staged(:added).first.path).to eq('added.txt')

    #     expect(result.unstaged(:modified).size).to eq(1)
    #     expect(result.unstaged(:modified).first.path).to eq('unstaged_modified.txt')

    #     expect(result.unstaged(:deleted).size).to eq(1)
    #     expect(result.unstaged(:deleted).first.path).to eq('unstaged_deleted.txt')
    #   end
    # end

    # context 'with empty output' do
    #   it 'returns an empty report' do
    #     result = described_class.parse('')

    #     expect(result.branch).to be_nil
    #     expect(result.stash).to be_nil
    #     expect(result.entries).to be_empty
    #     expect(result.clean?).to be true
    #   end
    # end
  end
end
