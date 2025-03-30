# frozen_string_literal: true

RSpec.describe RubyGit::Repository do
  let(:repository) { RubyGit::Repository.new(repository_path, normalize_path:) }
  let(:repository_path) { '.' }

  describe '#initialize' do
    subject { repository }

    around do |example|
      in_temp_dir do |_repository_path|
        example.run
      end
    end

    context 'when normalize_path is true' do
      let(:normalize_path) { true }
      it 'path should be the absolute path to the repository' do
        expected_path = File.realpath(File.expand_path(repository_path))
        expect(subject).to have_attributes(path: expected_path)
      end
    end

    context 'when normalize_path is false' do
      let(:normalize_path) { false }
      it 'path should be as given' do
        expect(subject).to have_attributes(path: repository_path)
      end
    end
  end
end
