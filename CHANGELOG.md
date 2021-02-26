# Unreleased (`master`)

# 1.7

This release adds support for `nil` values in the ordering list. Thanks to
[yfulmes](https://github.com/yfulmes) for requesting this feature!

# 1.6

We are dropping official support for Ruby 2.3 and below, though they may
continue to work.

This release adds support for ordering by `Range`s. Big thanks to
[Karl-Aksel Puulmann](https://github.com/macobo) for adding this functionality!

# 1.5

This release improves performance by switching to use `CASE` statements. Huge
thanks to [Yen-Nan (Maso) Lin](https://github.com/masolin) for this improvement!

# 1.4

This release removes deprecation warnings for ActiveRecord 5.2 users, and drops
support for ActiveRecord 4.x. Many thanks to
[George Protacio-Karaszi](https://github.com/GeorgeKaraszi) for pointing out
this issue!

# 1.3

This release adds support for ActiveRecord 5.1. Many thanks to
[cohki0305](https://github.com/cohki0305) for identifying the issue,
[Billy Ferguson](https://github.com/fergyfresh) for investigating it, and
especially to [Alex Heeton](https://github.com/heeton) for fixing it.

# 1.2

This release contains an important change: `order_as_specified` is no longer
vulnerable to SQL injection attacks. Big thanks to
[Anthony Mangano](https://github.com/wangteji) for finding and fixing this
issue.

In addition, this release corrects an error in the `.gemspec`—this gem relies on
ActiveRecord >= 4.0.1, not 4.0.0.

# 1.1

This release contains several minor changes:

- Tests now run against Ruby 2.2.5 and 2.3.1 and Rails 4.2 and 5.0.
- A code change was made to fix a Rails 5 deprecation warning.

# 1.0

We've hit our first major release! This release contains **no** breaking
changes. The changes:

- Added `:distinct_on` option. [[#3](https://github.com/panorama-ed/order_as_specified/issues/3)]
- Improved error message for `nil` arguments. [[#8](https://github.com/panorama-ed/order_as_specified/pull/8)]

# 0.1.0

The initial release! All basic functionality is in here.
