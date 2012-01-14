class CreateValidations < ActiveRecord::Migration
  def change
    create_table :validations do |t|
      t.text :key
      t.references :user_id
      t.boolean :valid, :default => false

      t.timestamps
    end
    add_index :validations, :user_id_id
  end
end
