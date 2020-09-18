# frozen_string_literal: true

task default: %i[spec bundle:audit rubocop yardstick verify_measurements yard build]

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

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w[
    --require spec_helper.rb
    --color
    --format documentation
  ]
end

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

# yardstick

require 'yardstick/rake/verify'
Yardstick::Rake::Verify.new do |verify|
  verify.threshold = 100
end

desc 'Run yardstick to check yard docs'
task :yardstick do
  sh "yardstick 'lib/**/*.rb'"
end
