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

    context "input safety" do
      before(:each) { TestClass.create(field: "foo") }

      it "sanitizes column values" do
        # Attempt to inject code to add a 'hi' field to each record. If the SQL inputs
        # are properly sanitized, the code will be ignored and the returned model
        # instances will not respond to #hi. If not, the code will execute and
        # each of the returned model instances will have a #hi method to access the
        # new field.
        bad_value = "foo') field, 'hi'::varchar AS hi FROM test_classes --"
        record = TestClass.order_as_specified(distinct_on: true, field: [bad_value]).to_a.first
        expect(record).to_not respond_to(:hi)
      end
    end
  end
end
