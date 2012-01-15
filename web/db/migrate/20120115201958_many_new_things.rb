class ManyNewThings < ActiveRecord::Migration
  def change
    drop_table :seeders
    drop_table :validation_keys
    add_column :devices , :confirmed_at , :datetime
  end
end
