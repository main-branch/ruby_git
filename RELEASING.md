# How to release a new ruby_git gem

Releasing a new version of the `ruby_git` gem requires these steps:
  * [Prepare the release](#prepare-the-release)
  * [Create a GitHub release](#create-a-github-release)
  * [Build and release the gem](#build-and-release-the-gem)

These instructions use an example where the current release version is `1.0.0`
and the new release version to be created is `1.1.0.pre1`.

## Prepare the release

On a branch (or fork) of ruby_git, create a PR containing changes to (1) bump the
version number and (2) update the CHANGELOG.md, and (3) tag the release.

  * Bump the version number
    * Version number is in lib/ruby_git/version.rb
    * Follow [Semantic Versioning](https://semver.org) guidelines
    * `bundle exec bump patch` # bugfixes only
    * `bundle exec bump minor` # bugfixes only
    * `bundle exec bump major` # bugfixes only
    
  * Update CHANGELOG.md
    * `bundle exec rake changelog`

  * Stage the changes to be committed
    * `git add lib/ruby_git/version.rb CHANGELOG.md`

  * Commit, tag, and push changes to the repository
    * ```git release `ruby -I lib -r ruby_git -e 'puts RubyGit::VERSION'` ```

  * Create a PR with these changes, have it reviewed and approved, and merged to main.

## Create a GitHub release

On [the ruby_git releases page](https://github.com/jcouball/ruby_git/releases),
select `Draft a new release`

  * Select the tag corresponding to the version being released `v1.1.0.pre1`
  * The Target should be `main`
  * For the release description, copy the relevant section from the CHANGELOG.md
    * The release description can be edited later.
  * Select the appropriate value for `This is a pre-release`
    * Since `v1.1.0.pre1` is a pre-release, check `This is a pre-release`

## Build and release the gem

Clone [jcouball/ruby_git](https://github.com/jcouball/ruby_git) directly (not a
fork) and ensure your local working copy is on the main branch

  * Verify that you are not on a fork with the command `git remote -v`
  * Verify that the version number is correct by running `rake -T` and inspecting
    the output for the `release[remote]` task

Build the git gem and push it to rubygems.org with the command `rake release`

  * Ensure that your `gem sources list` includes `https://rubygems.org` (in my
    case, I usually have my work’s internal gem repository listed)