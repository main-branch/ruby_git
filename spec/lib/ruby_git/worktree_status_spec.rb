# frozen_string_literal: true

require 'tmpdir'

# @param untracked_files [:all, :normal, :no] Defines how untracked files will be
# handled
#
#   See [git-staus
#   --untracked-files](https://git-scm.com/docs/git-status#Documentation/git-status.txt---untracked-filesltmodegt).
#
# @param ignored [:traditional, :matching, :no] Defines how ignored files will be
# handled, :no to not include ignored files
#
#   See [git-staus
#   --ignored](https://git-scm.com/docs/git-status#Documentation/git-status.txt---ignoredltmodegt).
#
# @param ignore_submodules [:all, :dirty, :untracked, :none] Default is :all
#
#   See [git-staus
#   --ignore-submodules](https://git-scm.com/docs/git-status#Documentation/git-status.txt---ignore-submodulesltwhengt).
#

RSpec.describe RubyGit::Worktree do
  let(:worktree) { described_class.open(worktree_path) }
  let(:worktree_path) { '.' }

  describe '.status' do
    subject { worktree.status(untracked_files:, ignored:, ignore_submodules:) }
    let(:untracked_files) { :all }
    let(:ignored) { :no }
    let(:ignore_submodules) { :all }

    context 'for a working tree with no commits and no changes' do
      around do |example|
        in_temp_dir do
          run %w[git init --initial-branch=main]
          example.run
        end
      end

      it 'should report no changes' do
        expect(subject).to have_attributes(entries: [])
      end

      it 'should report the branch name "main" and OID nil' do
        expect(subject.branch).to have_attributes(name: 'main', oid: nil)
      end
    end

    context 'for a working tree with no changes' do
      around do |example|
        in_temp_dir do
          run %w[git init --initial-branch=main]
          run %w[git commit --allow-empty -m commit_1]
          example.run
        end
      end

      it 'should report no changes' do
        expect(subject).to have_attributes(entries: [])
      end

      it 'should report the branch name "main" and OID SHA' do
        expect(subject.branch).to have_attributes(name: 'main', oid: a_string_matching(/^\h+$/))
      end
    end

    context 'a working tree with two changes' do
      around do |example|
        in_temp_dir do
          run %w[git init --initial-branch=main]
          File.write('file_1', 'content_1')
          File.write('file_2', 'content_2')
          run %w[git add file_1 file_2]
          run %w[git commit -m commit_1]
          File.write('file_1', 'content_1_changed')
          File.write('file_2', 'content_2_changed')
          example.run
        end
      end

      it 'should report the two changes' do
        expect(subject.entries.map(&:path)).to contain_exactly('file_1', 'file_2')
      end
    end

    context 'when run from a directory outside the working tree' do
      let(:worktree_path) { @worktree_path }

      around do |example|
        in_temp_dir do
          in_dir 'working_tree' do
            @worktree_path = Dir.pwd

            run %w[git init --initial-branch=main]
            File.write('file_1', 'content_1')
            File.write('file_2', 'content_2')
            run %w[git add file_1 file_2]
            run %w[git commit -m commit_1]
            File.write('file_1', 'content_1_changed')
            File.write('file_2', 'content_2_changed')

            Dir.chdir('..') do
              example.run
            end
          end
        end
      end

      it 'should be successfully report the changes within the working tree' do
        expect(subject.entries.map(&:path)).to contain_exactly('file_1', 'file_2')
      end
    end

    context 'building the right status command' do
      subject { worktree.status(*given_args, **given_options) }

      let(:given_args) { [] }
      let(:given_options) { {} }

      let(:subject_object) { worktree }
      let(:result) { instance_double(RubyGit::CommandLine::Result, stdout: '') }

      base_command =
        %w[status --porcelain=v2
           --branch --show-stash --ahead-behind --renames -z
           --untracked-files=all --ignored=no --ignore-submodules=all]

      context 'when no options are given' do
        it_behaves_like 'it runs the git command', [base_command]
      end

      context 'when a non-default untracked_files is given' do
        let(:given_options) { { untracked_files: :normal } }
        expected_command = base_command.sub('--untracked-files=all', '--untracked-files=normal')
        it_behaves_like 'it runs the git command', [expected_command]
      end

      context 'when ignored is given' do
        let(:given_options) { { ignored: :matching } }
        expected_command = base_command.sub('--ignored=no', '--ignored=matching')
        it_behaves_like 'it runs the git command', [expected_command]
      end

      context 'when ignore_submodules is given' do
        let(:given_options) { { ignore_submodules: :dirty } }
        expected_command = base_command.sub('--ignore-submodules=all', '--ignore-submodules=dirty')
        it_behaves_like 'it runs the git command', [expected_command]
      end

      context 'when a path spec is given' do
        let(:given_args) { ['lib'] }
        it_behaves_like 'it runs the git command', [[*base_command, '--', 'lib']]
      end

      context 'when multiple path specs are given' do
        let(:given_args) { %w[lib spec] }
        it_behaves_like 'it runs the git command', [[*base_command, '--', 'lib', 'spec']]
      end
    end
  end
end
