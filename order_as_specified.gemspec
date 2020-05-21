# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
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

  spec.add_dependency "activerecord", ">= 5.0.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "mysql2"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-rails"

  # Older versions of Rails locked in the SQLite3 version, so we have to
  # explicitly specify the version here
  sqlite3 = ENV["ACTIVERECORD_VERSION"] == "~> 5.0.0" ? "~> 1.3.13" : "~> 1.4"
  spec.add_development_dependency "sqlite3", sqlite3
end
