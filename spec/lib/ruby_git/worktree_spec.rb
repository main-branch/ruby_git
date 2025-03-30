# frozen_string_literal: true

RSpec.describe RubyGit::Worktree do
  let(:worktree) { RubyGit::Worktree.open(worktree_path, normalize_path:) }
  let(:worktree_path) { '.' }
  let(:normalize_path) { true }

  describe '#initialize' do
    subject { worktree }

    around do |example|
      in_temp_dir do
        run %w[git init --initial-branch=main]
        Dir.mkdir('subdir')
        example.run
      end
    end

    context 'when normalize_path is true' do
      let(:normalize_path) { true }
      context 'when worktree_path is the working tree root directory' do
        let(:worktree_path) { '.' }
        it 'should have a path to the working tree root directory' do
          expected_path = File.realpath(File.expand_path(worktree_path))
          expect(subject).to have_attributes(path: expected_path)
        end
      end

      context 'when worktree_path is a subdirectory within the working tree' do
        let(:worktree_path) { 'subdir' }
        it 'should have a path to the working tree root directory' do
          expected_path = File.realpath(File.expand_path('.'))
          expect(subject).to have_attributes(path: expected_path)
        end
      end
    end

    context 'when normalize_path is false' do
      let(:normalize_path) { false }
      let(:worktree_path) { 'blah/blah/blah' }
      it 'should have the given path' do
        expect(subject).to have_attributes(path: worktree_path)
      end
    end
  end

  describe '#repository' do
    around do |example|
      in_temp_dir do |worktree_path|
        @worktree_path = worktree_path
        run %w[git init --initial-branch=main]
        example.run
      end
    end

    subject { worktree.repository }

    it { is_expected.to be_a(RubyGit::Repository) }
    it { is_expected.to have_attributes(path: File.realpath('./.git')) }
  end
end
