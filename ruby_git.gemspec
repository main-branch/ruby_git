# frozen_string_literal: true

require_relative 'lib/ruby_git/version'

Gem::Specification.new do |spec|
  spec.name          = 'ruby_git'
  spec.version       = RubyGit::VERSION
  spec.authors       = ['James Couball']
  spec.email         = ['jcouball@yahoo.com']
  spec.license       = 'MIT'

  spec.summary       = 'A Ruby library to work with Git Respositories'
  spec.description   = <<~DESCRIPTION
    THIS PROJECT IS A WORK IN PROGRESS AND IS NOT USEFUL IN ITS CURRENT STATE

    An object-oriented interface to working with Git Repositories that
    tries to make sense out of the Git command line.
  DESCRIPTION
  spec.homepage = 'https://github.com/main-branch/ruby_git/'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1.0')
  spec.requirements = [
    'Git 2.28.0 or later',
    'Ruby 3.1 or later',
    'Only MRI Ruby and JRuby are officially supported.',
    'Mac, Linux, Unix, and Windows platforms are supported'
  ]

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/main-branch/ruby_git/'
  spec.metadata['changelog_uri'] = 'https://github.com/main-branch/ruby_git/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'null-logger', '~> 0.1'

  spec.add_development_dependency 'bump', '~> 0.10'
  spec.add_development_dependency 'bundler-audit', '~> 0.9'
  spec.add_development_dependency 'rake', '~> 13.2'
  spec.add_development_dependency 'redcarpet', '~> 3.6'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'rubocop', '~> 1.66'
  spec.add_development_dependency 'simplecov', '0.17'
  spec.add_development_dependency 'yard', '~> 0.9'
  spec.add_development_dependency 'yardstick', '~> 0.9'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
