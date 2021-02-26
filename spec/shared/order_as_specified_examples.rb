# frozen_string_literal: true

require "support/application_record"
require "support/test_class"
require "support/association_test_class"

RSpec.shared_examples ".order_as_specified" do
  # Clean up after each test. This is a lot lighter for these few tests than
  # trying to wrangle with RSpec-Rails to get transactional tests to work.
  after :each do
    TestClass.delete_all
    AssociationTestClass.delete_all
  end

  let(:shuffled_objects) do
    Array.new(5) { |i| TestClass.create(field: "Field #{i}") }.shuffle
  end
  let(:shuffled_object_fields) { shuffled_objects.map(&:field) }
  let(:shuffled_object_ids) { shuffled_objects.map(&:id) }
  let(:omitted_object) { TestClass.create(field: "Nothing") }

  context "with no table name specified" do
    subject { TestClass.order_as_specified(field: shuffled_object_fields) }

    it "returns results including unspecified objects" do
      omitted_object # Build an object that isn't sorted in this list.
      expect(subject).to include omitted_object
    end

    it "returns results in the given order" do
      omitted_object # Build an object that isn't sorted in this list.
      expect(subject.map(&:id)).
        to eq [*shuffled_object_ids, omitted_object.id]
    end

    context "when the order is chained with other orderings" do
      subject do
        TestClass.
          order_as_specified(field: shuffled_object_fields.take(3)).
          order(:id)
      end

      it "returns results in the given order by multiple fields" do
        shuffled_objects # Build these objects first.
        omitted_object # Build an object that isn't sorted in this list.
        expect(subject.map(&:id)).to eq [
          *shuffled_object_ids.take(3),
          *shuffled_object_ids.drop(3).sort,
          omitted_object.id
        ]
      end
    end

    context "when the order includes nil" do
      let(:shuffled_objects) do
        Array.new(5) do |i|
          TestClass.create(field: (i == 0 ? nil : "Field #{i}"))
        end.shuffle
      end

      it "returns results in the given order" do
        expect(subject.map(&:id)).to eq shuffled_object_ids
      end
    end
  end

  context "when the order is empty array" do
    subject { TestClass.order_as_specified(field: []) }

    let(:test_objects) do
      Array.new(5) do |i|
        TestClass.create(field: "Field #{i}")
      end
    end

    it "keep the original order" do
      test_objects # Build test objects
      expect(subject.map(&:id)).
        to eq test_objects.map(&:id)
    end
  end

  context "when the order is a range" do
    subject do
      TestClass.order_as_specified(number_field: ranges).order(:number_field)
    end

    let(:ranges) { [(3..4), (0..2)] }
    let(:numbers) { [0, 1, 2, 3, 4] }

    let!(:test_objects) do
      numbers.each do |i|
        TestClass.create(number_field: i)
      end
    end

    it "sorts according to range" do
      expect(subject.map(&:number_field)).to eq [
        *numbers.drop(3),
        *numbers.take(3)
      ]
    end

    context "when ranges are exclusive" do
      let(:numbers) { [0, 1, 2, 3, 4, 0.9, 1.5] }

      let(:ranges) { [(1...2), (0...1), (2...5)] }

      it "sorts according to range" do
        expect(subject.map(&:number_field)).to eq [
          1,
          1.5,
          0,
          0.9,
          2,
          3,
          4
        ]
      end
    end

    context "when ranges are in reverse order" do
      let(:ranges) { [(5..0)] }

      it "raises an error" do
        expect { subject }.to raise_error(OrderAsSpecified::Error)
      end
    end
  end

  context "with another table name specified" do
    subject do
      TestClass.
        joins(:association_test_class).
        order_as_specified(
          association_test_classes: { id: associated_object_ids }
        )
    end

    let(:associated_objects) do
      shuffled_objects.map do |object|
        AssociationTestClass.create(test_class: object)
      end
    end
    let(:associated_object_ids) { associated_objects.map(&:id) }
    let(:omitted_associated_object) do
      AssociationTestClass.create(test_class: omitted_object)
    end

    it "returns results including unspecified objects" do
      # Build an object that isn't sorted in this list.
      omitted_associated_object

      expect(subject).to include omitted_object
    end

    it "returns results in the given order" do
      # Build an object that isn't sorted in this list.
      omitted_associated_object

      expect(subject.map(&:id)).
        to eq [*shuffled_object_ids, omitted_object.id]
    end
  end

  describe "input safety" do
    before(:each) do
      2.times { |i| TestClass.create(field: "foo#{i}") }
    end

    it "sanitizes column values" do
      # Verify that the result set includes two records when using good column
      # value.
      good_value = "foo"
      records = TestClass.order_as_specified(field: [good_value]).to_a
      expect(records.count).to eq(2)

      # Attempt to inject a LIMIT clause into the query. If the SQL inputs are
      # properly sanitized, it will be ignored and the returned result set will
      # include two records. If not, the LIMIT clause will execute and the
      # result set will include just one record.
      bad_value = "' LIMIT 1 --"
      records = TestClass.order_as_specified(field: [bad_value]).to_a
      expect(records.count).to eq(2)
    end

    it "quotes column and table names" do
      table = "association_test_classes"
      quoted_table = AssociationTestClass.connection.quote_table_name(table)

      column = "id"
      quoted_column = AssociationTestClass.connection.quote_column_name(column)

      sql = TestClass.order_as_specified(table => { column => ["foo"] }).to_sql
      pattern = "ORDER BY (CASE WHEN #{quoted_table}.#{quoted_column}"
      expect(sql).to include(pattern)
    end
  end

  context "when hash input is invalid" do
    subject { TestClass.order_as_specified({}) }

    it "raises an error" do
      expect { subject }.to raise_error(OrderAsSpecified::Error)
    end
  end

  context "when case insensitive option is used" do
    subject do
      TestClass.
        order_as_specified(field: %w[abc def], case_insensitive: true).
        pluck(TestClass.arel_table[:field].lower)
    end

    before :each do
      TestClass.create!(
        [
          { field: "dEf" },
          { field: "aBc" },
          { field: "ABC" },
          { field: "DEF" }
        ]
      )
    end

    it "orders in a case insensitive manner" do
      expect(subject).to eq(%w[abc abc def def])
    end
  end
end
