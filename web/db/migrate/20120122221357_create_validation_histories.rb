class CreateValidationHistories < ActiveRecord::Migration
  def change
    create_table :validation_histories do |t|
      t.references :validation
      t.references :device

      t.timestamps
    end
    add_index :validation_histories, :validation_id
    add_index :validation_histories, :device_id
  end
end
