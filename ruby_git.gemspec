# frozen_string_literal: true

require_relative 'lib/ruby_git/version'

Gem::Specification.new do |spec|
  spec.name          = 'ruby_git'
  spec.version       = RubyGit::VERSION
  spec.authors       = ['James Couball']
  spec.email         = ['jcouball@yahoo.com']
  spec.license       = 'MIT'

  spec.summary       = 'An object-oriented interface to working with the git command line'
  spec.description   = <<~DESCRIPTION
    An object-oriented interface to the git command line. See PLAN.md for
    project progress.
  DESCRIPTION
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1.0')
  spec.requirements = [
    'Platform: Mac, Linux, or Windows',
    'Ruby: MRI 3.1 or later, TruffleRuby 24 or later, or JRuby 9.4 or later',
    'Git 2.28.0 or later'
  ]

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  # Project links
  spec.homepage = "https://github.com/main-branch/#{spec.name}"
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['documentation_uri'] = "https://rubydoc.info/gems/#{spec.name}/#{spec.version}"
  spec.metadata['changelog_uri'] = "https://rubydoc.info/gems/#{spec.name}/#{spec.version}/file/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler-audit', '~> 0.9'
  spec.add_development_dependency 'command_line_boss', '~> 0.2'
  spec.add_development_dependency 'create_github_release', '~> 2.1'
  spec.add_development_dependency 'main_branch_shared_rubocop_config', '~> 0.1'
  spec.add_development_dependency 'rake', '~> 13.2'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'rubocop', '~> 1.74'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'simplecov-lcov', '~> 0.8'
  spec.add_development_dependency 'simplecov-rspec', '~> 0.4'

  unless RUBY_PLATFORM == 'java'
    spec.add_development_dependency 'redcarpet', '~> 3.6'
    spec.add_development_dependency 'yard', '~> 0.9', '>= 0.9.28'
    spec.add_development_dependency 'yardstick', '~> 0.9'
  end

  spec.add_dependency 'process_executer', '~> 4.0'
  spec.add_dependency 'rchardet', '~> 1.9'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
