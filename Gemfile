# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in order_as_specified.gemspec
gemspec

if ENV["TRAVIS"] == "true" && ENV["ACTIVERECORD_VERSION"]
  gem "activerecord", ENV["ACTIVERECORD_VERSION"]
end
