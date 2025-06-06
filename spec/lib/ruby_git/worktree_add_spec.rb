# frozen_string_literal: true

RSpec.describe RubyGit::Worktree do
  let(:worktree) { described_class.open(worktree_path) }

  describe '#add' do
    subject { worktree.add(*pathspecs, **options) }

    describe 'adding changes to the index' do
      let(:worktree_path) { @worktree_path }

      around do |example|
        in_temp_dir do |path|
          @worktree_path = path
          run %w[git init --initial-branch=main]
          File.write('file1.txt', 'file1 contents')
          File.write('file2.txt', 'file2 contents')
          Dir.mkdir 'subdir'
          File.write('subdir/file3.txt', 'file3 contents')
          example.run
        end
      end

      context 'when told to add all changes into the index' do
        def untracked_entries
          worktree.status.entries.select { |entry| entry.is_a?(RubyGit::Status::UntrackedEntry) }
        end

        it 'should add files to the index' do
          expect { worktree.add('.') }.to change { untracked_entries.count }.from(3).to(0)
        end
      end
    end

    describe 'calling the git add command line' do
      let(:worktree) { described_class.new(worktree_path) }
      let(:worktree_path) { '/some/worktree_path' } # Dummy path for testing

      let(:subject_object) { worktree } # for the it_behaves_like 'it runs the git command'
      let(:result) { instance_double(RubyGit::CommandLine::Result, stdout: '') }

      context 'with called with no arguments' do
        let(:pathspecs) { [] }
        let(:options) { {} }

        it_behaves_like 'it runs the git command', [%w[add]]
      end

      context 'with with a pathspec' do
        let(:pathspecs) { %w[file1.txt] }
        let(:options) { {} }

        it_behaves_like 'it runs the git command', [%w[add -- file1.txt]]
      end

      context 'with two pathspecs' do
        let(:pathspecs) { %w[file1.txt file2.txt] }
        let(:options) { {} }

        it_behaves_like 'it runs the git command', [%w[add -- file1.txt file2.txt]]
      end

      context 'with the all option' do
        context 'all: true' do
          let(:pathspecs) { [] }
          let(:options) { { all: true } }

          it_behaves_like 'it runs the git command', [%w[add --all]]
        end

        context 'all: false' do
          let(:pathspecs) { [] }
          let(:options) { { all: false } }

          it_behaves_like 'it runs the git command', [%w[add]]
        end

        context 'all: invalid' do
          let(:pathspecs) { [] }
          let(:options) { { all: 'invalid' } }

          it_behaves_like 'it raises a RubyGit::ArgumentError',
                          %(The 'all:' option must be a Boolean value but was "invalid")
        end
      end

      context 'with the force option' do
        context 'force: true' do
          let(:pathspecs) { [] }
          let(:options) { { force: true } }

          it_behaves_like 'it runs the git command', [%w[add --force]]
        end

        context 'force: false' do
          let(:pathspecs) { [] }
          let(:options) { { force: false } }

          it_behaves_like 'it runs the git command', [%w[add]]
        end

        context 'force: invalid' do
          let(:pathspecs) { [] }
          let(:options) { { force: 'invalid' } }

          it_behaves_like(
            'it raises a RubyGit::ArgumentError',
            %(The 'force:' option must be a Boolean value but was "invalid")
          )
        end
      end

      context 'with the update option' do
        context 'update: true' do
          let(:pathspecs) { [] }
          let(:options) { { update: true } }

          it_behaves_like 'it runs the git command', [%w[add --update]]
        end

        context 'update: false' do
          let(:pathspecs) { [] }
          let(:options) { { update: false } }

          it_behaves_like 'it runs the git command', [%w[add]]
        end

        context 'update: invalid' do
          let(:pathspecs) { [] }
          let(:options) { { update: 'invalid' } }

          it_behaves_like(
            'it raises a RubyGit::ArgumentError',
            %(The 'update:' option must be a Boolean value but was "invalid")
          )
        end
      end

      context 'with the refresh option' do
        context 'refresh: true' do
          let(:pathspecs) { [] }
          let(:options) { { refresh: true } }

          it_behaves_like 'it runs the git command', [%w[add --refresh]]
        end

        context 'refresh: false' do
          let(:pathspecs) { [] }
          let(:options) { { refresh: false } }

          it_behaves_like 'it runs the git command', [%w[add]]
        end

        context 'refresh: invalid' do
          let(:pathspecs) { [] }
          let(:options) { { refresh: 'invalid' } }

          it_behaves_like(
            'it raises a RubyGit::ArgumentError',
            %(The 'refresh:' option must be a Boolean value but was "invalid")
          )
        end
      end
    end
  end
end
