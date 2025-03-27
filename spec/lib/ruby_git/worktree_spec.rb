# frozen_string_literal: true

RSpec.describe RubyGit::Worktree do
  describe '#repository' do
    let(:worktree) { RubyGit::Worktree.open(worktree_path) }
    let(:worktree_path) { @worktree_path }

    around do |example|
      in_temp_dir do |worktree_path|
        @worktree_path = worktree_path
        run %w[git init --initial-branch=main]
        example.run
      end
    end

    subject { worktree.repository }

    it { is_expected.to be_a(RubyGit::Repository) }
    it { is_expected.to have_attributes(path: File.expand_path('./.git')) }
  end
end
