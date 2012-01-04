class CreateValidationKeys < ActiveRecord::Migration
  def change
    create_table :validation_keys do |t|
      t.references :seeder
      t.text :data

      t.timestamps
    end
    add_index :validation_keys, :seeder_id
  end
end
