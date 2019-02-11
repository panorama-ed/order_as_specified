# Releasing

## These are steps for the maintainer to take to release a new version of this gem.

1. Create a new branch for bumping the version.
1. On the new branch, update the VERSION constant in `lib/order_as_specified/version.rb`.
1. Update the Changelog.
1. Commit the change: `git add -A && git commit -m 'Bump to vX.X'`.
1. Make a PR.
1. Merge the PR.
1. Add a tag: `git tag -am "vX.X" vX.X`.
1. Push the tag: `git push --tags`
1. Push to rubygems: `gem build order_as_specified.gemspec && gem push *.gem && rm *.gem`
1. Celebrate!
