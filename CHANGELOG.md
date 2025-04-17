# Change Log

## [0.3.5](https://github.com/main-branch/ruby_git/compare/v0.3.4...v0.3.5) (2025-04-17)


### Features

* Add initial_branch option to RubyGit::Worktree.init ([9f5e8da](https://github.com/main-branch/ruby_git/commit/9f5e8daca1599d46c9a53429b24f4fff47f148b6))
* Add initial_branch option to RubyGit.init ([c0007e5](https://github.com/main-branch/ruby_git/commit/c0007e501c2768e921c1aef618c8edb4969e5e95))


### Bug Fixes

* Automate commit-to-publish workflow ([9850fed](https://github.com/main-branch/ruby_git/commit/9850fed2230f154eaf6319644d0e6b40c5352e7f))
* Do not trigger build workflows after merging to main or for release PRs ([0678dd3](https://github.com/main-branch/ruby_git/commit/0678dd347235aaa9f55d84853de94d01935f974d))
* Move unneeded builds from continuous_integration to experimental_ruby_builds ([2d15e1c](https://github.com/main-branch/ruby_git/commit/2d15e1c7aef848e4d3cc857e6f606a0f68d7bf6f))
* Rewrap any errors raised by Process.spawn in RubyGit::SpawnError ([1ed4444](https://github.com/main-branch/ruby_git/commit/1ed4444c12ff1598af8915eac0c568bbaa865c84))
* Update changelog sections in release-please-config ([b34078a](https://github.com/main-branch/ruby_git/commit/b34078add703edf32d128efd64c12c45edffd21b))


### Other Changes

* Create release PR as draft and change release PR title ([aa39ed9](https://github.com/main-branch/ruby_git/commit/aa39ed95191a0678b8916b010b9abf6e99d94372))
* Fix JSON syntax error in release-please config ([165f3c1](https://github.com/main-branch/ruby_git/commit/165f3c1cd57a0fbdc98631b880095239b84423d6))
* **main:** Release 0.3.2 ([ae04872](https://github.com/main-branch/ruby_git/commit/ae04872fc4f7e4e6f8d374cb745f8fa0ba4acb5a))
* **main:** Release 0.3.3 ([bc0b3e5](https://github.com/main-branch/ruby_git/commit/bc0b3e5e538974b4a3e3ec33449453842cbd50d7))
* Make path normalization for Worktree and Repository optional ([c8b07f6](https://github.com/main-branch/ruby_git/commit/c8b07f6580df7894a45e6b3f9fb54f3a2725f218))
* Move option validators to their own module ([e5107f9](https://github.com/main-branch/ruby_git/commit/e5107f93fb12d2d56ed618217f3e362afce4adaf))
* Release v0.3.4 ([6dc79dd](https://github.com/main-branch/ruby_git/commit/6dc79dddec7f316a8cd10df05dd14d320aaee77e))
* Remove Code Climate integration ([fbb9dd7](https://github.com/main-branch/ruby_git/commit/fbb9dd75f358d35f04282eb2ee87e76f2a354762))
* Revert changes to make path normalization optional ([aa56519](https://github.com/main-branch/ruby_git/commit/aa56519051c32e7a5e5ec2361a02ef3d985e876e))
* Update to latest version of process_executer which has fixes ([71a0151](https://github.com/main-branch/ruby_git/commit/71a0151a1d5512fc46e5e00adec7185f89cd2ec9))

## [0.3.4](https://github.com/main-branch/ruby_git/compare/v0.3.3...v0.3.4) (2025-04-17)


### Features

* Add initial_branch option to RubyGit::Worktree.init ([9f5e8da](https://github.com/main-branch/ruby_git/commit/9f5e8daca1599d46c9a53429b24f4fff47f148b6))
* Add initial_branch option to RubyGit.init ([c0007e5](https://github.com/main-branch/ruby_git/commit/c0007e501c2768e921c1aef618c8edb4969e5e95))


### Bug Fixes

* Rewrap any errors raised by Process.spawn in RubyGit::SpawnError ([1ed4444](https://github.com/main-branch/ruby_git/commit/1ed4444c12ff1598af8915eac0c568bbaa865c84))

## [0.3.3](https://github.com/main-branch/ruby_git/compare/v0.3.2...v0.3.3) (2025-04-17)


### Bug Fixes

* Do not trigger build workflows after merging to main or for release PRs ([0678dd3](https://github.com/main-branch/ruby_git/commit/0678dd347235aaa9f55d84853de94d01935f974d))
* Move unneeded builds from continuous_integration to experimental_ruby_builds ([2d15e1c](https://github.com/main-branch/ruby_git/commit/2d15e1c7aef848e4d3cc857e6f606a0f68d7bf6f))

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
