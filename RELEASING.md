# How to release a new ruby_git gem

Run `create-github-release <release-type>` in the root of a clean working tree.

Where `release-type` is `major`, `minor`, or `patch` depending on the nature of the
changes. Refer to the labels on each PR since the last release to determine which
semver release type to specify.

Follow the directions that `create-github-release` after it prepares the release PR.
