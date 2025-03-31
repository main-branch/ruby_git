# frozen_string_literal: true

RSpec.describe RubyGit::Repository do
  let(:repository) { RubyGit::Repository.new(repository_path) }
  let(:repository_path) { '.' }

  describe '#initialize' do
    subject { repository }

    around do |example|
      in_temp_dir do
        run %w[git init --initial-branch=main]
        example.run
      end
    end

    it 'path should be the absolute path to the repository' do
      expected_path = File.realpath(File.expand_path(repository_path))
      expect(subject).to have_attributes(path: expected_path)
    end
  end
end
