# frozen_string_literal: true

require 'tmpdir'

RSpec.describe RubyGit::GitBinary do
  let(:git_binary) { described_class.new }

  describe '.default_path' do
    context 'with no basename' do
      subject { described_class.default_path }
      let(:dir) { Dir.mktmpdir }
      after { FileUtils.rm_rf dir }

      context "when 'git' is not in the path" do
        it 'should raise a RuntimeError' do
          saved_env = ENV.to_hash
          begin
            ENV.replace({ 'PATH' => dir })
            expect { subject }.to raise_error(RuntimeError)
          ensure
            ENV.replace(saved_env)
          end
        end
      end

      context "when 'git' is in the path" do
        it 'should return a Pathname to the the first executable file in the PATH whose basename is git' do
          saved_env = ENV.to_hash
          begin
            ENV.replace({ 'PATH' => dir })
            path = Pathname.new(File.join(dir, 'git'))
            FileUtils.touch(path)
            path.chmod(0o755)

            expect(subject).to be_kind_of(Pathname)
            expect(subject).to eq(path)
          ensure
            ENV.replace(saved_env)
          end
        end
      end
    end

    context "with basename 'mygit'" do
      basename = 'mygit'
      subject { described_class.default_path(basename: basename) }

      context "and '#{basename}' is not in the PATH and 'git' is in the PATH" do
        it 'should raise a RuntimeError' do
          Dir.mktmpdir do |dir|
            saved_env = ENV.to_hash
            begin
              ENV.replace({ 'PATH' => dir })

              path = Pathname.new(File.join(dir, 'git'))
              FileUtils.touch(path)
              path.chmod(0o755)
              expect { subject }.to raise_error(RuntimeError)
            ensure
              ENV.replace(saved_env)
            end
          end
        end
      end

      context "and '#{basename}' is in the PATH but not a file" do
        it 'should raise a RuntimeError' do
          Dir.mktmpdir do |dir|
            saved_env = ENV.to_hash
            begin
              ENV.replace({ 'PATH' => dir })
              path = Pathname.new(File.join(dir, basename))
              FileUtils.mkdir(path)
              path.chmod(0o755)
              expect { subject }.to raise_error(RuntimeError)
            ensure
              ENV.replace(saved_env)
            end
          end
        end
      end

      context "and '#{basename}' is in the PATH but not executable file" do
        it 'should raise a RuntimeError' do
          Dir.mktmpdir do |dir|
            saved_env = ENV.to_hash
            begin
              ENV.replace({ 'PATH' => dir })
              path = Pathname.new(File.join(dir, basename))
              FileUtils.mkdir(path)
              path.chmod(0o666)
              expect { subject }.to raise_error(RuntimeError)
            ensure
              ENV.replace(saved_env)
            end
          end
        end
      end

      context "and PATHEXT is '.exe;.com'" do
        context "and '#{basename}.com' is an executable file in the path" do
          it 'should not raise a RuntimeError' do
            Dir.mktmpdir do |dir|
              saved_env = ENV.to_hash
              begin
                ENV.replace({ 'PATH' => dir, 'PATHEXT' => '.com;.exe' })
                path = Pathname.new(File.join(dir, "#{basename}.com"))
                FileUtils.touch(path)
                path.chmod(0o755)
                expect { subject }.not_to raise_error
              ensure
                ENV.replace(saved_env)
              end
            end
          end
        end

        context "and '#{basename}.exe' is an executable file in the path" do
          it 'should not raise a RuntimeError' do
            Dir.mktmpdir do |dir|
              saved_env = ENV.to_hash
              begin
                ENV.replace({ 'PATH' => dir, 'PATHEXT' => '.com;.exe' })
                path = Pathname.new(File.join(dir, "#{basename}.exe"))
                FileUtils.touch(path)
                path.chmod(0o755)
                expect { subject }.not_to raise_error
              ensure
                ENV.replace(saved_env)
              end
            end
          end
        end

        context "when neither '#{basename}.com' or '#{basename}.exe' are an executable file in the path" do
          it 'should raise a RuntimeError' do
            Dir.mktmpdir do |dir|
              saved_env = ENV.to_hash
              begin
                ENV.replace({ 'PATH' => dir, 'PATHEXT' => '.com;.exe' })
                path = Pathname.new(File.join(dir, 'git.fubar'))
                FileUtils.touch(path)
                path.chmod(0o755)
                expect { subject }.to raise_error(RuntimeError)
              ensure
                ENV.replace(saved_env)
              end
            end
          end
        end
      end
    end
  end

  describe '#path=' do
    subject { described_class.new.path = new_path }
    let(:dir) { Dir.mktmpdir }
    after { FileUtils.rm_rf dir }

    context 'when given a path that is not convertable to a string' do
      let(:new_path) { 1 }
      it 'should raise a TypeError' do
        expect { subject }.to raise_error(TypeError)
      end
    end

    context 'when given a path that does not exist' do
      let(:new_path) { Pathname.new(File.join(dir, 'git')) }
      it 'should raise a RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when set to a path that is not a file' do
      let(:new_path) { Pathname.new(File.join(dir, 'git')) }
      it 'should raise a RuntimeError' do
        Dir.mktmpdir do |_dir|
          FileUtils.mkdir(new_path)
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end

    context 'when set to a path that is not an executable file' do
      let(:new_path) { Pathname.new(File.join(dir, 'git')) }
      it 'should raise a RuntimeError' do
        Dir.mktmpdir do |_dir|
          FileUtils.touch(new_path)
          new_path.chmod(0o644)
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end

    context 'when set to a path that is an executable file' do
      let(:new_path) { Pathname.new(File.join(dir, 'git')) }
      it 'should return the path' do
        Dir.mktmpdir do |_dir|
          FileUtils.touch(new_path)
          new_path.chmod(0o755)
          expect { subject }.not_to raise_error
          expect(subject).to eq(new_path)
        end
      end
    end

    context 'when path is given as a string' do
      let(:new_path) { Pathname.new(File.join(dir, 'git')) }
      it 'should return a Pathname' do
        Dir.mktmpdir do |_dir|
          FileUtils.touch(new_path)
          FileUtils.chmod(0o755, new_path)
          expect { subject }.not_to raise_error
          expect(subject).to eq(new_path)
          expect(subject).to be_kind_of(Pathname)
        end
      end
    end

    context 'when set to a path that is a symlink to an executable file' do
      let(:new_path) { Pathname.new(File.join(dir, 'symlink_to_git')) }
      it 'should not raise an error' do
        Dir.mktmpdir do |dir|
          actual_path = Pathname.new(File.join(dir, 'git'))
          FileUtils.touch(actual_path)
          actual_path.chmod(0o755)
          FileUtils.ln_s(actual_path, new_path)
          expect { subject }.not_to raise_error
          expect(subject).to eq(new_path)
        end
      end
    end
  end

  describe '#path' do
    let(:git_binary) { described_class.new }
    subject { git_binary.path }
    let(:dir) { Dir.mktmpdir }
    after { FileUtils.rm_rf dir }

    context 'when path was not set' do
      context 'and git is in the PATH' do
        it 'should find the git in the PATH' do
          saved_env = ENV.to_hash
          begin
            ENV.replace({ 'PATH' => dir })
            path = Pathname.new(File.join(dir, 'git'))
            FileUtils.touch(path)
            FileUtils.chmod(0o755, path)
            expect(subject).to be_kind_of(Pathname)
            expect(subject).to eq(path)
          ensure
            ENV.replace(saved_env)
          end
        end
      end

      context 'and git is not in the PATH' do
        it 'should raise a RuntimeError' do
          saved_env = ENV.to_hash
          begin
            ENV.replace({ 'PATH' => dir })
            expect { subject }.to raise_error(RuntimeError)
          ensure
            ENV.replace(saved_env)
          end
        end
      end
    end

    context 'when path was set' do
      let(:new_path) { Pathname.new(File.join(dir, 'mygit')) }
      before do
        FileUtils.touch(new_path)
        FileUtils.chmod(0o755, new_path)
        git_binary.path = new_path
      end
      it 'should return what path was set to' do
        expect(subject).to eq(new_path)
      end
    end

    context 'when path has been set to a file not in the PATH' do
      context 'and a different git exists in the PATH' do
        it 'should return what path was originally set to' do
          directory_in_path = File.join(dir, 'dir1')
          FileUtils.mkdir(directory_in_path)
          git_in_path = Pathname.new(File.join(directory_in_path, 'git'))
          FileUtils.touch(git_in_path)
          FileUtils.chmod(0o755, git_in_path)

          directory_not_in_path = File.join(dir, 'dir2')
          FileUtils.mkdir(directory_not_in_path)
          git_not_in_path = Pathname.new(File.join(directory_not_in_path, 'git'))
          FileUtils.touch(git_not_in_path)
          FileUtils.chmod(0o755, git_not_in_path)

          saved_env = ENV.to_hash
          begin
            ENV.replace({ 'PATH' => directory_in_path })
            git_binary.path = git_not_in_path

            expect(subject).to eq(git_not_in_path)
          ensure
            ENV.replace(saved_env)
          end
        end
      end
    end
  end

  describe '#version' do
    subject { git_binary.version }
    let(:dir) { Dir.mktmpdir }
    after { FileUtils.rm_rf dir }
    it 'should return the version returned from --version' do
      saved_env = ENV.to_hash
      begin
        ENV.replace({ 'PATH' => "#{dir}:#{ENV['PATH']}" })
        path = Pathname.new(File.join(dir, 'git'))
        File.write(path, <<~SCRIPT)
          #!/usr/bin/env sh
          if [ "$1" != '--version' ]; then echo '--version required'; exit 1; fi
          echo 'git version 10.11.12'
        SCRIPT
        FileUtils.chmod(0o755, path)
        expect(subject).to eq([10, 11, 12])
      ensure
        ENV.replace(saved_env)
      end
    end
  end
end
