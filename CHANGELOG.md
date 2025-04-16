# Change Log

## [0.3.2](https://github.com/main-branch/ruby_git/compare/v0.3.1...v0.3.2) (2025-04-16)


### Bug Fixes

* Automate commit-to-publish workflow ([9850fed](https://github.com/main-branch/ruby_git/commit/9850fed2230f154eaf6319644d0e6b40c5352e7f))

## v0.3.1 (2025-03-28)

[Full Changelog](https://github.com/main-branch/ruby_git/compare/v0.3.0..v0.3.1)

Changes since v0.3.0:

* fbadc20 docs: update the gem description

## v0.3.0 (2025-03-28)

[Full Changelog](https://github.com/main-branch/ruby_git/compare/v0.2.0..v0.3.0)

Changes since v0.2.0:

* 89cf543 chore: add the implementation plan
* 3e952c0 feat: add status report entry filters
* 301c7b7 feat: support git add via Worktree#add
* 72020b9 feat: add support to passing path specs to Worktree#status
* 324a472 test: add tests to verify that Worktree#status builds the right git command
* c07b3be feat: make Worktree#clone work if clone_to path is not given
* d7a3232 feat: add Worktree#status
* 7bae4b6 feat: implement RubyGit::Worktree#status
* f75e0ec chore: rename working tree to worktree
* 918487c chore: run git commands using RubyGit::CommandLine.run
* 8a5b204 fix: fix tests failing on Windows for platform-specific reasons
* 19eb327 fix: make it so command-line-test script runs in Windows
* 7fb57c5 refactor: change the way that the git command is run
* 6efdf53 chore: update process_executer dependency to 3.0
* 834b33d test: add command line tool to run to test running the command line
* e74affb chore: make it easier to identify the platform and ruby engine in scripts
* ceaf40d build: remove semver pr label check
* 6e56dd0 build: enforce conventional commit message formatting
* 209c408 Replace NullLogger with Logger.new(File::NULL)
* 9b23e0f Use shared Rubocop config
* acb286e Update copyright notice in this project
* 549d8fb Update links in gemspec
* 6de1b82 Use standard badges at the top of the README
* 1fa584e Update yardopts with new standard options
* 872cd1b Rename "markdown.yml" to ".markdown.yml"
* ec8299a Standardize YARD and Markdown Lint configurations
* 1862fc9 Update CODEOWNERS file
* 6de3eea Set JRuby --debug option when running tests in GitHub Actions workflows
* 50fda86 Integrate simplecov-rspec into the project
* 4b7410b Use create-github-release for creating releases
* 5fd999b Reset CodeClimate code coverage reporter id
* 7944490 Update continuous integration and experimental ruby builds
* 943c687 Enforce the use of semver tags on PRs
* 4e7126a Update minimum required Ruby to 3.1
* 359c358 Don't enforce coverage % in an RSpec dry run (#30)
* efa2c90 Use GitHub Actions for CI Builds (#29)
* d1ca85b Upgrade to Rubocop 1.0 (#25)
* 6c8fd7a Rename Worktree class to WorkingTree (#24)
* 88f7471 Remove MAINTAINERS.md from yard documentation (#23)
* a55042d Add logging to the RubyGit gem (#22)
* 9a95a32 Redesign RubyGit::FileHelpers.which (#20)
* 9bb7dc0 Allow members of @main-branch/ruby_git-codeowners to do code review approvals. (#19)
* 401e1fd Release v0.2.0 (#18)

## [v0.2.0](https://github.com/main-branch/ruby_git/releases/tag/v0.2.0) (2020-10-12)

[Full Changelog](https://github.com/main-branch/ruby_git/compare/v0.1.3...v0.2.0)

**Merged pull requests:**

- Add Worktree class and creation methods init, clone, and open [\#17](https://github.com/main-branch/ruby_git/pull/17) ([jcouball](https://github.com/jcouball))
- Add Slack badge to README [\#16](https://github.com/main-branch/ruby_git/pull/16) ([jcouball](https://github.com/jcouball))
- Push code coverage information to CodeClimate [\#14](https://github.com/main-branch/ruby_git/pull/14) ([jcouball](https://github.com/jcouball))
- Move the ruby\_git repository to the main-branch GitHub organization. [\#13](https://github.com/main-branch/ruby_git/pull/13) ([jcouball](https://github.com/jcouball))
- Add CODEOWNERS file [\#12](https://github.com/main-branch/ruby_git/pull/12) ([jcouball](https://github.com/jcouball))
- Release v0.1.3 [\#11](https://github.com/main-branch/ruby_git/pull/11) ([jcouball](https://github.com/jcouball))

## [v0.1.3](https://github.com/main-branch/ruby_git/releases/tag/v0.1.3) (2020-09-24)

[Full Changelog](https://github.com/main-branch/ruby_git/compare/v0.1.2...v0.1.3)

**Merged pull requests:**

- Add Gem badge and correct home page URL [\#10](https://github.com/main-branch/ruby_git/pull/10) ([jcouball](https://github.com/jcouball))

## [v0.1.2](https://github.com/main-branch/ruby_git/releases/tag/v0.1.2) (2020-09-24)

[Full Changelog](https://github.com/main-branch/ruby_git/compare/v0.1.1...v0.1.2)

**Merged pull requests:**

- Release v0.1.2 [\#9](https://github.com/main-branch/ruby_git/pull/9) ([jcouball](https://github.com/jcouball))
- Update instructions for creating releases and updating the changelog [\#8](https://github.com/main-branch/ruby_git/pull/8) ([jcouball](https://github.com/jcouball))
- Changes requested in documentation review [\#7](https://github.com/main-branch/ruby_git/pull/7) ([jcouball](https://github.com/jcouball))
- Set and retrieve the path to the git binary used by this library [\#6](https://github.com/main-branch/ruby_git/pull/6) ([jcouball](https://github.com/jcouball))
- Move RSpec config from Rakefile to .rspec [\#5](https://github.com/main-branch/ruby_git/pull/5) ([jcouball](https://github.com/jcouball))
- Release v0.1.1 [\#4](https://github.com/main-branch/ruby_git/pull/4) ([jcouball](https://github.com/jcouball))

## [v0.1.1](https://github.com/main-branch/ruby_git/releases/tag/v0.1.1) (2020-09-18)

[Full Changelog](https://github.com/main-branch/ruby_git/compare/v0.1.0...v0.1.1)

**Merged pull requests:**

- Add notice saying that this project is a work in progress [\#3](https://github.com/main-branch/ruby_git/pull/3) ([jcouball](https://github.com/jcouball))
- Remove Gemfile.lock and add it to .gitignore [\#2](https://github.com/main-branch/ruby_git/pull/2) ([jcouball](https://github.com/jcouball))

## [v0.1.0](https://github.com/main-branch/ruby_git/releases/tag/v0.1.0) (2020-09-18)

[Full Changelog](https://github.com/main-branch/ruby_git/compare/04b4b2bc59b0b09ad45a69572450cb393dbe79a1...v0.1.0)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
