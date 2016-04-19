require "spec_helper"
require "shared/order_as_specified_examples"
require "config/test_setup_migration"

RSpec.describe "PostgreSQL" do
  before :all do
    ActiveRecord::Base.establish_connection(:postgresql_test)
    TestSetupMigration.migrate(:up)
  end

  after(:all) { ActiveRecord::Base.remove_connection }

  include_examples ".order_as_specified"

  context "when using DISTINCT ON" do
    subject do
      TestClass.order_as_specified(
        distinct_on: true,
        field: shuffled_object_fields
      )
    end

    let(:shuffled_objects) do
      fields = 3.times.map { |i| "Field #{i}" } * 2
      5.times.map { |i| TestClass.create(field: fields[i]) }.shuffle
    end

    it "returns distinct objects" do
      expect(subject.length).to eq 3
    end
  end
end
