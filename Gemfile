# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

gem "panolint", github: "panorama-ed/panolint"

if ENV["TRAVIS"] == "true" && ENV["ACTIVERECORD_VERSION"]
  gem "activerecord", ENV["ACTIVERECORD_VERSION"]
end
