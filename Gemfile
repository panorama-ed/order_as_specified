# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in unique_attributes.gemspec
gemspec

group :development do
  gem "mysql2"
  gem "panolint-ruby", github: "panorama-ed/panolint-ruby", branch: "main"
  gem "pg"
  gem "rspec"
  gem "rspec-rails"
  gem "sqlite3"
end
