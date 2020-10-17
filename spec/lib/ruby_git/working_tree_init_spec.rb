# frozen_string_literal: true

require 'tmpdir'

RSpec.describe RubyGit::WorkingTree do
  describe '.init(working_tree_path)' do
    subject { described_class.init(working_tree_path) }
    let(:tmpdir) { Dir.mktmpdir }
    after { FileUtils.rm_rf(tmpdir) if File.exist?(tmpdir) }

    context 'when working_tree_path does not exist' do
      let(:working_tree_path) { tmpdir }
      before { FileUtils.rmdir(tmpdir) }
      it 'should raise a RubyGit::Error' do
        expect { subject }.to raise_error(RubyGit::Error)
      end
    end

    context 'when working_tree_path exists' do
      let(:working_tree_path) { tmpdir }
      context 'and is not a directory' do
        before do
          FileUtils.rmdir(working_tree_path)
          FileUtils.touch(working_tree_path)
        end
        it 'should raise RubyGit::Error' do
          expect { subject }.to raise_error(RubyGit::Error)
        end
      end

      context 'and is a directory' do
        context 'and is in a working tree' do
          before do
            raise RuntimeError unless system('git init', chdir: working_tree_path, %i[out err] => IO::NULL)
          end
          it 'should return a WorkingTree object to the existing working tree' do
            expect(subject).to be_kind_of(RubyGit::WorkingTree)
            expect(subject).to have_attributes(path: File.realpath(working_tree_path))
          end
        end

        context 'and is not in the working tree' do
          it 'should initialize the working tree and return a WorkingTree object' do
            expect(subject).to be_kind_of(RubyGit::WorkingTree)
            expect(subject).to have_attributes(path: File.realpath(working_tree_path))
          end
        end
      end
    end
  end
end
