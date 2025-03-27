# frozen_string_literal: true

RSpec.describe RubyGit::Repository do
  let(:repository) { RubyGit::Repository.new(repository_path) }

  describe '#initialize' do
    subject { repository }

    context 'when given a repository path' do
      let(:repository_path) { File.expand_path('/path/to/repository') }

      it 'should set the path to the given repository path' do
        expect(subject).to have_attributes(path: repository_path)
      end
    end
  end
end
