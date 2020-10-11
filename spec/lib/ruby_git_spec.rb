# frozen_string_literal: true

require 'tmpdir'

RSpec.describe RubyGit do
  it 'should have a version number' do
    expect(RubyGit::VERSION).not_to be nil
  end

  describe '.git_binary' do
    subject { described_class.git }
    it { is_expected.to be_kind_of(RubyGit::GitBinary) }
  end

  describe '.init' do
    let(:worktree_path) { '/Users/jsmith/my_project' }
    subject { RubyGit.init(worktree_path) }
    it 'should call RubyGit::Worktree.init with the same arguments' do
      worktree_class = class_double('RubyGit::Worktree')
      stub_const('RubyGit::Worktree', worktree_class)
      expect(worktree_class).to receive(:init).with(worktree_path)
      subject
    end
  end

  describe '.clone' do
    let(:repository_url) { 'https://github.com/main-branch/ruby_git.git' }
    subject { RubyGit.clone(repository_url) }
    it 'should call RubyGit::Worktree.clone with the same arguments' do
      worktree_class = class_double('RubyGit::Worktree')
      stub_const('RubyGit::Worktree', worktree_class)
      expect(worktree_class).to receive(:clone).with(repository_url, to_path: '')
      subject
    end
  end

  describe '.open' do
    let(:worktree_path) { '/Users/jsmith/my_project' }
    subject { RubyGit.open(worktree_path) }
    it 'should call RubyGit::Worktree.open with the same arguments' do
      worktree_class = class_double('RubyGit::Worktree')
      stub_const('RubyGit::Worktree', worktree_class)
      expect(worktree_class).to receive(:open).with(worktree_path)
      subject
    end
  end
end
