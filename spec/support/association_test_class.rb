class AssociationTestClass < ApplicationRecord
  extend OrderAsSpecified

  belongs_to :test_class
end
