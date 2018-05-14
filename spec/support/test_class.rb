# frozen_string_literal: true

class TestClass < ApplicationRecord
  extend OrderAsSpecified

  has_one :association_test_class
end
