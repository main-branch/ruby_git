# frozen_string_literal: true

RSpec.describe RubyGit::Repository do
  let(:repository) { RubyGit::Repository.new(repository_path) }
  let(:repository_path) { File.realpath(@repository_path) }

  describe '#initialize' do
    context 'when given a repository path' do
      around do |example|
        in_temp_dir do |repository_path|
          @repository_path = repository_path
          example.run
        end
      end

      subject { repository }

      it 'should set the path to the given repository path' do
        expect(subject).to have_attributes(path: repository_path)
      end
    end
  end
end
