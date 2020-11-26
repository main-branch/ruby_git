# frozen_string_literal: true

require 'tmpdir'

RSpec.describe RubyGit::FileHelpers do
  describe '.which' do
    subject { described_class.which(command, path: path, path_ext: path_ext) }
    let(:command) { 'command' }
    let(:path) { nil } # Equivalent to PATH not set in ENV
    let(:path_ext) { nil } # Equivalent to PATHEXT not set in ENV

    let(:root_dir) { Dir.mktmpdir }
    after { FileUtils.rm_rf root_dir }

    context 'when PATH is not set in ENV' do
      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context "when path is '/usr/bin:/usr/local/bin' and path_ext is nil" do
      let(:path_dir1) { File.join(root_dir, 'usr', 'bin') }
      let(:path_dir2) { File.join(root_dir, 'usr', 'local', 'bin') }
      let(:path) { [path_dir1, path_dir2].join(File::PATH_SEPARATOR) }

      context 'and command is not found in the path' do
        it { is_expected.to be_nil }
      end

      context 'and /usr/local/bin/command is NOT an executable file' do
        let(:command_dir) { path_dir1 }
        let(:command_path) { File.join(command_dir, command) }
        before do
          FileUtils.mkdir_p(command_dir)
          FileUtils.touch(command_path)
        end

        it { is_expected.to be_nil }
      end

      context 'and /usr/local/bin/command is a directory' do
        let(:command_dir) { path_dir1 }
        let(:command_path) { File.join(command_dir, command) }
        before do
          FileUtils.mkdir_p(command_dir)
          FileUtils.mkdir(command_path)
        end

        it { is_expected.to be_nil }
      end

      context 'and /usr/bin/command is an executable file' do
        let(:command_dir) { path_dir1 }
        let(:command_path) { File.join(command_dir, command) }
        before do
          FileUtils.mkdir_p(command_dir)
          FileUtils.touch(command_path)
          FileUtils.chmod(0o755, command_path)

          puts "PATHEXT='#{ENV['PATHEXT']}'"
          puts "command_path='#{command_path}'"
          puts "command_path.executable?=#{FileTest.executable?(command_path)}"
        end

        it { is_expected.to eq(Pathname.new(command_path)) }
      end

      context 'and /usr/local/bin/command is an executable file' do
        let(:command_dir) { path_dir2 }
        let(:command_path) { File.join(command_dir, command) }
        before do
          FileUtils.mkdir_p(command_dir)
          FileUtils.touch(command_path)
          FileUtils.chmod(0o755, command_path)
        end

        it { is_expected.to eq(Pathname.new(command_path)) }
      end

      context 'and /usr/local/bin/command is a symlink to an executable file' do
        let(:command_dir) { path_dir2 }
        let(:command_path) { File.join(command_dir, command) }
        let(:actual_command_path) { File.join(command_dir, "actual_#{command}") }
        before do
          FileUtils.mkdir_p(command_dir)
          FileUtils.touch(actual_command_path)
          FileUtils.chmod(0o755, actual_command_path)
          FileUtils.ln_s(actual_command_path, command_path)
        end

        it { is_expected.to eq(Pathname.new(command_path)) }
      end

      context 'and both /usr/bin/command and /usr/local/bin/command are executable files' do
        let(:command_dir1) { path_dir1 }
        let(:command_path1) { File.join(command_dir1, command) }
        before do
          FileUtils.mkdir_p(command_dir1)
          FileUtils.touch(command_path1)
          FileUtils.chmod(0o755, command_path1)
        end

        let(:command_dir2) { path_dir2 }
        let(:command_path2) { File.join(command_dir2, command) }
        before do
          FileUtils.mkdir_p(command_dir2)
          FileUtils.touch(command_path2)
          FileUtils.chmod(0o755, command_path2)
        end

        it { is_expected.to eq(Pathname.new(command_path1)) }
      end

      context "and path_ext is '.EXE:.BAT:.CMD'" do
        let(:path_dir1) { File.join(root_dir, 'usr', 'bin') }
        let(:path_dir2) { File.join(root_dir, 'usr', 'local', 'bin') }
        let(:path) { [path_dir1, path_dir2].join(File::PATH_SEPARATOR) }
        let(:path_ext) { %w[.EXE .BAT .CMD].join(File::PATH_SEPARATOR) }

        context 'and /usr/local/bin/command.BAT is an executable file' do
          let(:command_dir) { path_dir1 }
          let(:command_path) { File.join(command_dir, "#{command}.BAT") }
          before do
            FileUtils.mkdir_p(command_dir)
            FileUtils.touch(command_path)
            FileUtils.chmod(0o755, command_path)

            puts "PATHEXT='#{ENV['PATHEXT']}'"
            puts "command_path='#{command_path}'"
            puts "command_path.executable?=#{FileTest.executable?(command_path)}"
          end

          it { is_expected.to eq(Pathname.new(File.join(root_dir, '/usr/bin/command.BAT'))) }
        end
      end
    end
  end
end
