class TestSetupMigration < ActiveRecord::Migration
  def up
    return if ActiveRecord::Base.connection.data_source_exists?(:test_classes)

    create_table :test_classes do |t|
      t.string :field
    end

    create_table :association_test_classes do |t|
      t.integer :test_class_id
    end
  end

  def down
    drop_table :test_classes
    drop_table :association_test_classes
  end
end
