# RubyGit

**THIS PROJECT IS A WORK IN PROGRESS AND IS NOT USEFUL IN ITS CURRENT STATE**

[![Gem Version](https://badge.fury.io/rb/ruby_git.svg)](https://badge.fury.io/rb/ruby_git)
[![Build Status](https://travis-ci.org/main-branch/ruby_git.svg?branch=main)](https://travis-ci.org/main-branch/ruby_git)
[![Maintainability](https://api.codeclimate.com/v1/badges/5403e4613b7518f70da7/maintainability)](https://codeclimate.com/github/main-branch/ruby_git/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/5403e4613b7518f70da7/test_coverage)](https://codeclimate.com/github/main-branch/ruby_git/test_coverage)
[![Slack](https://img.shields.io/badge/slack-main--branch/ruby__git-yellow.svg?logo=slack)](https://main-branch.slack.com/archives/C01CHR7TMM2)

Git Is Hard™ but it doesn't have to be that way. Git has this reputation because it has an
underlying model that is more complex than other popular revision control systems 
such as CVS or Subversion. To make matters worse, the `git` command line is vast,
inconsistently implemented, and does not have a clear mapping between the command-line
actions and Git's underlying model.

Because of this complexity, beginners tend to memorize a few `git` commands in
order to get by with a simple workflow without really understanding how Git works
and the rich set of features it offers.

The RubyGit module provides a Ruby API that is an object-oriented wrapper around
the `git` command line. It is intended to make automating both simple and complex Git
interactions easier. To accomplish this, it ties each action you can do with `git` to
the type of object that action operates on.

There are three main objects in RubyGit:
 * [WorkingTree](lib/ruby_git/working_tree.rb): The directory tree of actual checked
   out files. The working tree normally contains the contents of the HEAD commit’s
   tree, plus any local changes that you have made but not yet committed.
 * [Index](lib/ruby_git/index.rb): The index is used as a staging area between your
   working tree and your repository. You can use the index to build up a set of changes
   that you want to commit together. When you create a commit, what is committed is what is
   currently in the index, not what is in your working directory.
 * [Repository](lib/ruby_git/repository.rb): The repository stores the files in a project,
   their history, and other meta data like commit information, tags, and branches.

The [RubyGit Class Diagram](RubyGit%20Class%20Diagram.svg) shows the main abstractions in
RubyGit, how they are related, and what actions each can perform. 

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

To work with an existing WorkingTree:

```Ruby
working_tree = RubyGit.open(working_tree_path)
working_tree.append_to_file('README.md', 'New line in README.md')
working_tree.add('README.md')
working_tree.commit('Add a line to the README.md')
working_tree.push
```

To create a new WorkingTree:

```Ruby
working_tree = RubyGit.init(working_tree_path)
working_tree.write_to_file('README.md', '# My New Project')
working_tree.add('README.md')
working_tree.repository.add_remote(remote_name: 'origin', url: 'https://github.com/jcouball/test', default_branch: 'main')
working_tree.push(remote_name: 'origin')
```

To tell what version of Git is being used:

```Ruby
puts RubyGit.git_version
```

The full API is documented in [the RubyGit YARD documentation](https://github.com/pages/main-branch/ruby_git).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bundle exec rake` to run tests, static analysis, and build the gem.

For experimentation, you can also run `bin/console` for an interactive (IRB) prompt that
automatically requires ruby_git.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/main-branch/ruby_git.
