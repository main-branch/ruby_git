# frozen_string_literal: true

require 'tmpdir'

def make_bare_repository(repository_path)
  Dir.mktmpdir do |tmpdir|
    system('git init', chdir: tmpdir, %i[out err] => IO::NULL)
    File.write(File.join(tmpdir, 'README.md'), '# THIS IS THE README')
    system('git add README.md', chdir: tmpdir, %i[out err] => IO::NULL)
    system('git commit -m "Initial version"', chdir: tmpdir, %i[out err] => IO::NULL)
    Dir[File.join(tmpdir, '.git', '*')].each do |path|
      FileUtils.mv(path, repository_path)
    end
  end
  repository_path
end

RSpec.describe RubyGit::WorkingTree do
  describe '.clone(url, to_path: working_tree_path)' do
    subject { described_class.clone(repository_url, to_path: working_tree_path) }
    let(:tmpdir) { Dir.mktmpdir }
    let(:repository_url) { make_bare_repository(Dir.mktmpdir) }
    after do
      FileUtils.rm_rf(tmpdir)
      FileUtils.rm_rf(repository_url)
    end

    context 'the url is not valid' do
      before { FileUtils.rm_rf(repository_url) }
      let(:working_tree_path) { tmpdir }
      it 'should raise RubyGit::Error' do
        expect { subject }.to raise_error(RubyGit::Error, /does not exist/)
      end
    end

    context 'the url is valid' do
      let(:working_tree_path) { tmpdir }

      context 'and working_tree_path exists' do
        context 'and is not an empty directory' do
          before { FileUtils.touch(File.join(working_tree_path, 'README.md')) }
          it 'should raise RubyGit::Error' do
            expect { subject }.to raise_error(RubyGit::Error, /not an empty directory/)
          end
        end

        context 'and is an empty directory' do
          it 'should return a  WorkingTree object' do
            expect(subject).to be_kind_of(RubyGit::WorkingTree)
            expect(subject).to have_attributes(path: File.realpath(working_tree_path))
          end
        end
      end
      context 'and working_tree_path does not exist' do
        before { FileUtils.rmdir(working_tree_path) }
        it 'should create the working tree path and return a WorkingTree object' do
          expect(subject).to be_kind_of(RubyGit::WorkingTree)
          expect(Dir.exist?(working_tree_path)).to eq(true)
          expect(subject).to have_attributes(path: File.realpath(working_tree_path))
        end
      end
    end
  end
end
