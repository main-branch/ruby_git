# RubyGit

**THIS PROJECT IS A WORK IN PROGRESS AND IS NOT USEFUL IN ITS CURRENT STATE**

[![Build Status](https://travis-ci.org/jcouball/ruby_git.svg?branch=main)](https://travis-ci.org/jcouball/ruby_git)
[![Maintainability](https://api.codeclimate.com/v1/badges/2d8d52a55d655b6a3def/maintainability)](https://codeclimate.com/github/jcouball/ruby_git/maintainability)

RubyGit is an object-oriented wrapper for the `git` command line tool for working with Worktrees
and Repositories. It tries to make more sense out of the Git command line. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby_git'
```

And then execute:

    $ bundle install

Or install it directly from the command line:

    $ gem install ruby_git

## Usage

To configure RubyGit:

```Ruby
RubyGit.git.path = '/usr/local/bin/git'

# Returns the user set path or searches for 'git' in ENV['PATH']
RubyGit.git.path #=> '/usr/local/bin/git'
RubyGit.git.version #=> [2,28,0]
```

To work with an existing Worktree:

```Ruby
worktree = RubyGit.open(worktree_path)
worktree.append_to_file('README.md', 'New line in README.md')
worktree.add('README.md')
worktree.commit('Add a line to the README.md')
worktree.push
```

To create a new Worktree:

```Ruby
worktree = RubyGit.init(worktree_path)
worktree.write_to_file('README.md', '# My New Project')
worktree.add('README.md')
worktree.repository.add_remote(remote_name: 'origin', url: 'https://github.com/jcouball/test', default_branch: 'main')
worktree.push(remote_name: 'origin')
```

To tell what version of Git is being used:

```Ruby
puts RubyGit.git_version
```

The full API is documented in [the RubyGit YARD documentation](https://github.com/pages/jcouball/ruby_git).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec`
to run the tests. You can also run `bin/console` for an interactive prompt that will allow
you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a
new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push git commits
and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jcouball/ruby_git.
