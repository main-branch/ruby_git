# frozen_string_literal: true

require 'tmpdir'
require 'logger'

RSpec.describe RubyGit do
  it 'should have a version number' do
    expect(RubyGit::VERSION).not_to be nil
  end

  describe '.logger' do
    subject { described_class.logger }

    context 'when a logger has not be set' do
      it { is_expected.to be_kind_of(Logger) }
    end

    context 'when a logger has been set' do
      let(:logger) { Logger.new($stdout, level: Logger::DEBUG) }
      before { RubyGit.logger = logger }
      it { is_expected.to eq(logger) }
    end
  end

  describe '.binary_path' do
    subject { described_class.binary_path }

    context 'when a binary path is not set by the user' do
      it { is_expected.to eq('git') }
    end

    context 'when a binary path is set by the user' do
      it 'should return the binary path set by the user' do
        saved_path = described_class.binary_path
        described_class.binary_path = '/usr/bin/git'
        expect(subject).to eq('/usr/bin/git')
        described_class.binary_path = saved_path
      end
    end
  end

  describe '.init' do
    subject { RubyGit.init(worktree_path, initial_branch:) }
    let(:worktree_path) { '/Users/jsmith/my_project' }
    let(:initial_branch) { 'xxx' }
    it 'should call RubyGit::Worktree.init with the same arguments' do
      worktree_class = class_double('RubyGit::Worktree')
      stub_const('RubyGit::Worktree', worktree_class)
      expect(worktree_class).to receive(:init).with(worktree_path, initial_branch:)
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

  describe '.binary_version' do
    subject { described_class.binary_version }
    context 'when "git --version" outputs "git version 10.11.12"' do
      let(:git_version_string) { 'git version 10.11.12' }
      let(:result) { double(RubyGit::CommandLine::Result, stdout: git_version_string) }
      it 'should return [10, 11, 12]' do
        expect(RubyGit::CommandLine).to receive(:run).with('version', Hash).and_return(result)
        expect(subject).to eq([10, 11, 12])
      end
    end
  end
end
