# frozen_string_literal: true

require 'logger'
require 'stringio'
require 'tmpdir'

RSpec.describe RubyGit::WorkingTree do
  describe '.initialize' do
    subject { described_class.open(working_tree_path) }
    let(:tmpdir) { Dir.mktmpdir }
    after { FileUtils.rm_rf(tmpdir) if File.exist?(tmpdir) }

    context 'with a valid working tree path' do
      let(:working_tree_path) { tmpdir }
      before do
        raise RuntimeError unless system('git init', chdir: working_tree_path, %i[out err] => IO::NULL)
      end
      it 'should log that a WorkingTree object was created at debug level' do
        log_device = StringIO.new
        saved_logger = RubyGit.logger
        RubyGit.logger = Logger.new(log_device, level: Logger::DEBUG)
        RubyGit::WorkingTree.new(working_tree_path)
        RubyGit.logger = saved_logger
        expect(log_device.string).to include(' : Created #<RubyGit::WorkingTree:')
      end
    end
  end
end
