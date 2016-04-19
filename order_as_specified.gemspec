# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "order_as_specified/version"

Gem::Specification.new do |spec|
  spec.name          = "order_as_specified"
  spec.version       = OrderAsSpecified::VERSION
  spec.authors       = ["Jacob Evelyn"]
  spec.email         = ["jevelyn@panoramaed.com"]
  spec.summary       = "Add arbitrary ordering to ActiveRecord queries."
  spec.description   = "Obtain ActiveRecord results with a custom ordering "\
                       "with no need to store anything in the database."
  spec.homepage      = "https://github.com/panorama-ed/order_as_specified"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 4.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 0.4"
  spec.add_development_dependency "overcommit", "~> 0.23"
  spec.add_development_dependency "pg", ">= 0.18"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "rspec-rails", "~> 3.2"
  spec.add_development_dependency "rubocop", "~> 0.29"
  spec.add_development_dependency "sqlite3", ">= 1.3"
end
