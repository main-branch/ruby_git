# frozen_string_literal: true

require 'tmpdir'

RSpec.describe RubyGit::Worktree do
  describe '.open' do
    subject { described_class.open(worktree_path) }
    let(:tmpdir) { Dir.mktmpdir }
    after { FileUtils.rm_rf(tmpdir) }

    context 'when worktree_path does not exist' do
      let(:worktree_path) { tmpdir }
      before { FileUtils.rmdir(worktree_path) }
      it 'should  raise ArgumentError' do
        expect { subject }.to raise_error(RubyGit::ArgumentError)
      end
    end

    context 'when worktree_path is not a directory' do
      let(:worktree_path) { tmpdir }
      before do
        FileUtils.rmdir(worktree_path)
        FileUtils.touch(worktree_path)
      end
      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(RubyGit::ArgumentError)
      end
    end

    context 'when worktree_path exists but is not a git working tree' do
      let(:worktree_path) { tmpdir }
      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(RubyGit::ArgumentError, /not a git repository/)
      end
    end

    context 'when worktree_path is a working tree path at the root of the working tree' do
      let(:worktree_path) { tmpdir }
      before do
        raise RuntimeError unless system('git init', chdir: worktree_path, %i[out err] => IO::NULL)
      end
      it 'should return a Worktree object whose path is the root of the working tree' do
        expect(subject).to be_kind_of(RubyGit::Worktree)
        expect(subject).to have_attributes(path: File.realpath(worktree_path))
      end
    end

    context 'when worktree_path is a working tree path not at the root of the working tree' do
      let(:root_worktree_path) { tmpdir }
      let(:worktree_path) { File.join(root_worktree_path, 'subdir') }
      before do
        raise RuntimeError unless system('git init', chdir: root_worktree_path, %i[out err] => IO::NULL)

        FileUtils.mkdir(worktree_path)
      end
      it 'should return a Worktree object whose path is the root of the worktree' do
        expect(subject).to have_attributes(path: File.realpath(root_worktree_path))
      end
    end
  end
end
