# frozen_string_literal: true

require 'tmpdir'

RSpec.describe RubyGit::GitBinary do
  context 'with no path in the initializer' do
    let(:git_binary) { described_class.new }

    describe '#initialize' do
      context 'when no path is given' do
        let(:git_binary) { described_class.new }

        it 'should have the default path' do
          expect(git_binary.path).to eq(Pathname.new('git'))
        end
      end

      context 'when a path is given' do
        let(:git_binary) { described_class.new('/usr/bin/git') }

        it 'should have the given path' do
          expect(git_binary.path).to eq(Pathname.new('/usr/bin/git'))
        end
      end
    end

    describe '#path=' do
      context 'when given a new path' do
        let(:new_path) { '/usr/bin/git' }
        it 'should set the path to the new path' do
          git_binary.path = new_path
          expect(git_binary.path).to eq(Pathname.new(new_path))
        end
      end
    end

    describe '#to_s' do
      let(:git_binary) { described_class.new }
      subject { git_binary.to_s }
      context "with '/usr/bin/git' passed in the initializer" do
        let(:git_binary) { described_class.new('/usr/bin/git') }
        it { is_expected.to eq('/usr/bin/git') }
      end
    end

    describe '#path' do
      let(:git_binary) { described_class.new }
      subject { git_binary.path }
      let(:dir) { Dir.mktmpdir }
      after { FileUtils.rm_rf dir }

      context "with '/usr/bin/git' passed in the initializer" do
        let(:git_binary) { described_class.new('/usr/bin/git') }
        it { is_expected.to eq(Pathname.new('/usr/bin/git')) }
      end
    end

    describe '#version' do
      subject { git_binary.version }
      context 'when "git --version" outputs "git version 10.11.12"' do
        let(:git_version_string) { 'git version 10.11.12' }
        it 'should return [10, 11, 12]' do
          expect(git_binary).to receive(:`).with("#{git_binary.path} --version").and_return(git_version_string)
          expect(subject).to eq([10, 11, 12])
        end
      end
    end
  end
end
