# frozen_string_literal: true

require 'logger'
require 'stringio'
require 'tmpdir'

RSpec.describe RubyGit::Worktree do
  describe '.initialize' do
    subject { described_class.open(worktree_path) }
    let(:tmpdir) { Dir.mktmpdir }
    after { FileUtils.rm_rf(tmpdir) if File.exist?(tmpdir) }

    context 'with a valid worktree path' do
      let(:worktree_path) { tmpdir }
      before do
        raise RuntimeError unless system('git init', chdir: worktree_path, %i[out err] => IO::NULL)
      end
      it 'should log that a Worktree object was created at debug level' do
        log_device = StringIO.new
        saved_logger = RubyGit.logger
        RubyGit.logger = Logger.new(log_device, level: Logger::DEBUG)
        RubyGit::Worktree.new(worktree_path)
        RubyGit.logger = saved_logger
        expect(log_device.string).to include(' : Created #<RubyGit::Worktree:')
      end
    end
  end
end
