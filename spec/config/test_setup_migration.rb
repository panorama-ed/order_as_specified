VersionedMigration = ActiveRecord::Migration.try(:[], 5.0) || ActiveRecord::Migration

class TestSetupMigration < VersionedMigration
  def up
    db_connection = ActiveRecord::Base.connection
    return if db_connection.try(:table_exists?, :test_classes) || # AR 4.2
              db_connection.try(:data_source_exists?, :test_classes) # AR > 5.0

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
