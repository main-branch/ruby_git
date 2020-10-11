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

RSpec.describe RubyGit::Worktree do
  describe '.clone(url, to_path: worktree_path)' do
    subject { described_class.clone(repository_url, to_path: worktree_path) }
    let(:tmpdir) { Dir.mktmpdir }
    let(:repository_url) { make_bare_repository(Dir.mktmpdir) }
    after do
      FileUtils.rm_rf(tmpdir) if File.exist?(tmpdir)
      FileUtils.rm_rf(repository_url) if File.exist?(repository_url)
    end

    context 'the url is not valid' do
      before { FileUtils.rm_rf(repository_url) }
      let(:worktree_path) { tmpdir }
      it 'should raise RubyGit::Error' do
        expect { subject }.to raise_error(RubyGit::Error, /does not exist/)
      end
    end

    context 'the url is valid' do
      let(:worktree_path) { tmpdir }

      context 'and worktree_path exists' do
        context 'and is not an empty directory' do
          before { FileUtils.touch(File.join(worktree_path, 'README.md')) }
          it 'should raise RubyGit::Error' do
            expect { subject }.to raise_error(RubyGit::Error, /not an empty directory/)
          end
        end

        context 'and is an empty directory' do
          it 'should return a  Worktree object' do
            expect(subject).to be_kind_of(RubyGit::Worktree)
            expect(subject).to have_attributes(path: File.realpath(worktree_path))
          end
        end
      end
      context 'and worktree_path does not exist' do
        before { FileUtils.rmdir(worktree_path) }
        it 'should create the worktree path and return a Worktree object' do
          expect(subject).to be_kind_of(RubyGit::Worktree)
          expect(Dir.exist?(worktree_path)).to eq(true)
          expect(subject).to have_attributes(path: File.realpath(worktree_path))
        end
      end
    end
  end
end
