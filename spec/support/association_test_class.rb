# frozen_string_literal: true

class AssociationTestClass < ApplicationRecord
  extend OrderAsSpecified

  belongs_to :test_class
end
