require "spec_helper"

RSpec.describe OrderAsSpecified do
  describe ".order_as_specified" do
    Temping.create :test_class do
      with_columns do |t|
        t.string :field
      end

      extend OrderAsSpecified

      has_one :association_test_class
    end

    Temping.create :association_test_class do
      with_columns do |t|
        t.integer :test_class_id
      end

      belongs_to :test_class
    end

    # Clean up after each test. This is a lot lighter for these few tests than
    # trying to wrangle with RSpec-Rails to get transactional tests to work.
    after :each do
      TestClass.delete_all
      AssociationTestClass.delete_all
    end

    let(:shuffled_objects) do
      5.times.map { |i| TestClass.create(field: "Field #{i}") }.shuffle
    end
    let(:shuffled_object_fields) { shuffled_objects.map(&:field) }
    let(:shuffled_object_ids) { shuffled_objects.map(&:id) }
    let(:omitted_object) { TestClass.create }

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
    end

    context "with another table name specified" do
      let(:associated_objects) do
        shuffled_objects.map do |object|
          AssociationTestClass.create(test_class: object)
        end
      end
      let(:associated_object_ids) { associated_objects.map(&:id) }
      let(:omitted_associated_object) do
        AssociationTestClass.create(test_class: omitted_object)
      end

      subject do
        TestClass.
          joins(:association_test_class).
          order_as_specified(
            association_test_classes: { id: associated_object_ids }
          )
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
  end
end
