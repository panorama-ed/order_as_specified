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
