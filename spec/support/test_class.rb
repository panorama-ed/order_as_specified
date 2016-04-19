class TestClass < ActiveRecord::Base
  extend OrderAsSpecified

  has_one :association_test_class
end
