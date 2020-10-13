# Contributing to ruby_git

Thank you for your interest in contributing to the ruby_git project!

This document gives the guidelines for contributing to this project.
These guidelines may not fit every situation.  When contributing use your best
judgement.

Propose changes to these guidelines with a pull request.

## How to contribute to ruby_git

You can contribute in two ways:

1. [Report an issue or make a feature request](#how-to-report-an-issue-or-make-a-feature-request)
2. [Submit a code or documentation change](#how-to-submit-a-code-or-documentation-change)

## How to report an issue or make a feature request

ruby_git utilizes [GitHub Issues](https://help.github.com/en/github/managing-your-work-on-github/about-issues)
for issue tracking and feature requests.

Report an issue or feature request by [creating a ruby_git Github issue](https://github.com/main-branch/ruby_git/issues/new).
Fill in the template to describe the issue or feature request the best you can.

## How to submit a code or documentation change

There is three step process for code or documentation changes:

1. [Commit your changes to a fork of ruby_git](#commit-changes-to-a-fork-of-ruby_git)
2. [Create a pull request](#create-a-pull-request)
3. [Get your pull request reviewed](#get-your-pull-request-reviewed)

### Commit changes to a fork of ruby_git

Make your changes in a fork of the ruby_git repository.

### Create a pull request

See [this article](https://help.github.com/articles/about-pull-requests/) if you
are not familiar with GitHub Pull Requests.

Follow the instructions in the pull request template.

### Get your pull request reviewed

Code review takes place in a GitHub pull request using the [the Github pull request review feature](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-request-reviews).

Once your pull request is ready for review, request a review from at least one of the
[code owners](https://github.com/orgs/main-branch/teams/ruby_git-codeowners/members).

During the review process, you may need to make additional commits which would
need to be squashed.  It may also be necessary to rebase to main again if other
changes are merged before your PR.

At least one approval is required from a project maintainer before your pull
request can be merged.  The maintainer is responsible for ensuring that the pull
request meets [the project's coding standards](#coding-standards).

## Coding standards

All pull requests must meet these requirements:

### 1 PR = 1 Commit
  * All commits for a PR must be squashed into one commit
  * To avoid an extra merge commit, the PR must be able to be merged as [a fast forward merge](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging)
  * The easiest way to ensure a fast forward merge is to rebase your local branch
    to the ruby_git main branch

### Unit tests
  * All changes must be accompanied by new or modified RSpec unit tests
  * The entire test suite must pass when `bundle exec rake spec` is run from the
    project's local working copy
  * The unit test suite must maintain 100% code coverage to pass 

### Documentation
  * New and updated public methods must have [YARD](https://yardoc.org/)
    documentation added to them
      * [The YARD Cheatsheet](https://gist.github.com/thelastinuit/5984665e6ab69d3c0a413a03602c45be)
        is a good reference
  * New and updated public facing features should be documented in the project's
    [README.md](README.md)
  * All documentation must pass `yardstick` documentation analysis
  * The documentation suite must maintain 100% documentation to pass

### Continuous Integration
  * All tests must pass in the project's [Travis CI](https://travis-ci.org/main-branch/ruby_git)
    build before the pull request will be merged.
  * You can simulate what happens in the Travis CI build by running `bundle exec rake` in 
    the projects root directory.

### Other Design Guidelines
  * Use keyword args with defaults instead of an opts hash

## Licensing

ruby_git uses [the MIT license](https://choosealicense.com/licenses/mit/) as
declared in the [LICENSE](LICENSE) file.

Licensing is very important to open source projects. It helps ensure the
software continues to be available under the terms that the author desired.

