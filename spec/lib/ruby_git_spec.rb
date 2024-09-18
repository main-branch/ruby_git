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

  describe '.git_binary' do
    subject { described_class.git }
    it { is_expected.to be_kind_of(RubyGit::GitBinary) }
  end

  describe '.init' do
    let(:working_tree_path) { '/Users/jsmith/my_project' }
    subject { RubyGit.init(working_tree_path) }
    it 'should call RubyGit::WorkingTree.init with the same arguments' do
      working_tree_class = class_double('RubyGit::WorkingTree')
      stub_const('RubyGit::WorkingTree', working_tree_class)
      expect(working_tree_class).to receive(:init).with(working_tree_path)
      subject
    end
  end

  describe '.clone' do
    let(:repository_url) { 'https://github.com/main-branch/ruby_git.git' }
    subject { RubyGit.clone(repository_url) }
    it 'should call RubyGit::WorkingTree.clone with the same arguments' do
      working_tree_class = class_double('RubyGit::WorkingTree')
      stub_const('RubyGit::WorkingTree', working_tree_class)
      expect(working_tree_class).to receive(:clone).with(repository_url, to_path: '')
      subject
    end
  end

  describe '.open' do
    let(:working_tree_path) { '/Users/jsmith/my_project' }
    subject { RubyGit.open(working_tree_path) }
    it 'should call RubyGit::WorkingTree.open with the same arguments' do
      working_tree_class = class_double('RubyGit::WorkingTree')
      stub_const('RubyGit::WorkingTree', working_tree_class)
      expect(working_tree_class).to receive(:open).with(working_tree_path)
      subject
    end
  end
end
