# frozen_string_literal: true

require "spec_helper"
require "shared/order_as_specified_examples"
require "config/test_setup_migration"

RSpec.describe "MySQL" do
  before :all do # rubocop:disable RSpec/BeforeAfterAll
    ActiveRecord::Base.establish_connection(:mysql_test)
    TestSetupMigration.migrate(:up)
  end

  after(:all) { ActiveRecord::Base.remove_connection } # rubocop:disable RSpec/BeforeAfterAll

  include_examples ".order_as_specified"
end
