class AssociationTestClass < ActiveRecord::Base
  extend OrderAsSpecified

  belongs_to :test_class
end
