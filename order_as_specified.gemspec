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
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 5.0.0"

  spec.metadata["rubygems_mfa_required"] = "true"
end
