# frozen_string_literal: true

# Instead of defining specs here, we define them in
# shared/order_as_specified_examples.rb. We then have a different spec file for
# each supported database adapter, whch runs the shared RSpec tests found in
# the shared/order_as_specified_examples.rb file, along with any adapter-
# specific tests.
