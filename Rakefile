# frozen_string_literal: true

task default: %i[spec bundle:audit rubocop yardstick:audit yardstick:coverage yard build]

# Bundler Audit

require 'bundler/audit/task'
Bundler::Audit::Task.new

# Bundler Gem Build

require 'bundler'
require 'bundler/gem_tasks'

# Bump

require 'bump/tasks'

# RSpec

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

CLEAN << 'coverage'
CLEAN << '.rspec_status'
CLEAN << 'rspec-report.xml'

# Rubocop

require 'rubocop/rake_task'

RuboCop::RakeTask.new do |t|
  t.options = %w[
    --format progress
    --format json --out rubocop-report.json
  ]
end

CLEAN << 'rubocop-report.json'

# YARD

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files = %w[lib/**/*.rb examples/**/*]
end

CLEAN << '.yardoc'
CLEAN << 'doc'

# Yardstick

desc 'Run yardstick to show missing YARD doc elements'
task :'yardstick:audit' do
  sh "yardstick 'lib/**/*.rb'"
end

# Yardstick coverage

require 'yardstick/rake/verify'

Yardstick::Rake::Verify.new(:'yardstick:coverage') do |verify|
  verify.threshold = 100
end

# Changelog

require 'github_changelog_generator/task'

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  config.header = '# Change Log'
  config.user = 'main-branch'
  config.project = 'ruby_git'
  config.future_release = "v#{RubyGit::VERSION}"
  config.release_url = 'https://github.com/main-branch/ruby_git/releases/tag/%s'
  config.author = true
end
