# frozen_string_literal: true

require 'tmpdir'

RSpec.describe RubyGit::WorkingTree do
  describe '.open' do
    subject { described_class.open(working_tree_path) }
    let(:tmpdir) { Dir.mktmpdir }
    after { FileUtils.rm_rf(tmpdir) if File.exist?(tmpdir) }

    context 'when working_tree_path does not exist' do
      let(:working_tree_path) { tmpdir }
      before { FileUtils.rmdir(working_tree_path) }
      it 'should  raise RubyGit::Error' do
        expect { subject }.to raise_error(RubyGit::Error)
      end
    end

    context 'when working_tree_path is not a directory' do
      let(:working_tree_path) { tmpdir }
      before do
        FileUtils.rmdir(working_tree_path)
        FileUtils.touch(working_tree_path)
      end
      it 'should raise RubyGit::Error' do
        expect { subject }.to raise_error(RubyGit::Error)
      end
    end

    context 'when working_tree_path exists but is not a git working tree' do
      let(:working_tree_path) { tmpdir }
      it 'should raise RubyGit::Error' do
        expect { subject }.to raise_error(RubyGit::Error, /not a git repository/)
      end
    end

    context 'when working_tree_path is a working tree path at the root of the working tree' do
      let(:working_tree_path) { tmpdir }
      before do
        raise RuntimeError unless system('git init', chdir: working_tree_path, %i[out err] => IO::NULL)
      end
      it 'should return a WorkingTree object whose path is the root of the working tree' do
        expect(subject).to be_kind_of(RubyGit::WorkingTree)
        expect(subject).to have_attributes(path: File.realpath(working_tree_path))
      end
    end

    context 'when working_tree_path is a working tree path not at the root of the working tree' do
      let(:root_working_tree_path) { tmpdir }
      let(:working_tree_path) { File.join(root_working_tree_path, 'subdir') }
      before do
        raise RuntimeError unless system('git init', chdir: root_working_tree_path, %i[out err] => IO::NULL)

        FileUtils.mkdir(working_tree_path)
      end
      it 'should return a WorkingTree object whose path is the root of the working_tree' do
        expect(subject).to have_attributes(path: File.realpath(root_working_tree_path))
      end
    end
  end
end
