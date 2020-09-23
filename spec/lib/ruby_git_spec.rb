# frozen_string_literal: true

require 'tmpdir'

RSpec.describe RubyGit do
  it 'should have a version number' do
    expect(RubyGit::VERSION).not_to be nil
  end

  describe '.git_binary' do
    subject { described_class.git }
    it { is_expected.to be_kind_of(RubyGit::GitBinary) }
  end
end
