# frozen_string_literal: true

require 'tmpdir'

RSpec.describe RubyGit::Worktree do
  describe '.init(worktree_path)' do
    subject { described_class.init(worktree_path) }
    let(:tmpdir) { Dir.mktmpdir }
    after { FileUtils.rm_rf(tmpdir) if File.exist?(tmpdir) }

    context 'when worktree_path does not exist' do
      let(:worktree_path) { tmpdir }
      before { FileUtils.rmdir(tmpdir) }
      it 'should raise a RubyGit::Error' do
        expect { subject }.to raise_error(RubyGit::Error)
      end
    end

    context 'when worktree_path exists' do
      let(:worktree_path) { tmpdir }
      context 'and is not a directory' do
        before do
          FileUtils.rmdir(worktree_path)
          FileUtils.touch(worktree_path)
        end
        it 'should raise RubyGit::Error' do
          expect { subject }.to raise_error(RubyGit::Error)
        end
      end

      context 'and is a directory' do
        context 'and is in a worktree' do
          before do
            raise RuntimeError unless system('git init', chdir: worktree_path, %i[out err] => IO::NULL)
          end
          it 'should return a Worktree object to the existing worktree    ' do
            expect(subject).to be_kind_of(RubyGit::Worktree)
            expect(subject).to have_attributes(path: File.realpath(worktree_path))
          end
        end

        context 'and is not in a worktree' do
          it 'should initialize the worktree and return a Worktree object' do
            expect(subject).to be_kind_of(RubyGit::Worktree)
            expect(subject).to have_attributes(path: File.realpath(worktree_path))
          end
        end
      end
    end
  end
end
