# frozen_string_literal: true

require 'tmpdir'

RSpec.describe RubyGit::Worktree do
  describe '.init' do
    subject { described_class.init(worktree_path, initial_branch: initial_branch) }
    let(:initial_branch) { nil }

    describe 'initializing a worktree' do
      let(:tmpdir) { @tmpdir }

      around do |example|
        in_temp_dir do |tmpdir|
          @tmpdir = tmpdir
          example.run
        end
      end

      context 'when worktree_path does not exist' do
        let(:worktree_path) { File.join(tmpdir, 'subdir') }

        expected_error = truffleruby? ? RubyGit::FailedError : RubyGit::SpawnError

        it "should raise an error #{expected_error}" do
          expect { subject }.to raise_error(expected_error)
        end
      end

      context 'when worktree_path exists' do
        let(:worktree_path) { tmpdir }
        context 'and is not a directory' do
          before do
            FileUtils.rmdir(worktree_path)
            FileUtils.touch(worktree_path)
          end

          expected_error = truffleruby? ? RubyGit::FailedError : RubyGit::SpawnError

          it "should raise a #{expected_error} " do
            expect { subject }.to raise_error(expected_error)
          end
        end

        context 'and is a directory' do
          context 'and is in a working tree' do
            before do
              raise RuntimeError unless system('git init', chdir: worktree_path, %i[out err] => IO::NULL)
            end
            it 'should return a Worktree object to the existing working tree' do
              expect(subject).to be_kind_of(RubyGit::Worktree)
              expect(subject).to have_attributes(path: File.realpath(worktree_path))
            end
          end

          context 'and is not in the working tree' do
            it 'should initialize the working tree and return a Worktree object' do
              expect(subject).to be_kind_of(RubyGit::Worktree)
              expect(subject).to have_attributes(path: File.realpath(worktree_path))
            end
          end
        end
      end
    end

    describe 'constructing the git command line' do
      let(:worktree_path) { '/my/worktree/path' }
      let(:result) { instance_double(RubyGit::CommandLine::Result, stdout: '') }

      before do
        allow(described_class).to(
          receive(:new).with(worktree_path).and_return(instance_double(RubyGit::Worktree))
        )
      end

      context 'called with no arguments' do
        let(:expected_command) { %w[init] }

        it 'should run the expected git command' do
          expect(RubyGit::CommandLine).to(
            receive(:run).with(*expected_command, Hash).and_return(result)
          )

          subject
        end
      end

      describe 'initial_branch option' do
        context 'when nil' do
          let(:expected_command) { %w[init] }

          it 'should run the expected git command' do
            expect(RubyGit::CommandLine).to(
              receive(:run).with(*expected_command, Hash).and_return(result)
            )
            subject
          end
        end

        context 'when a string' do
          let(:expected_command) { ['init', '--initial-branch', initial_branch] }
          let(:initial_branch) { 'my-branch' }

          it 'should run the expected git command' do
            expect(RubyGit::CommandLine).to(
              receive(:run).with(*expected_command, Hash).and_return(result)
            )
            subject
          end
        end

        context 'when not a string' do
          let(:initial_branch) { 123 }

          it 'should raise an ArgumentError' do
            expect { subject }.to(
              raise_error(ArgumentError, %(The 'initial_branch:' option must be a String or nil but was 123))
            )
          end
        end
      end
    end
  end
end
