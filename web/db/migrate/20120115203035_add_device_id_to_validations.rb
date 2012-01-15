class AddDeviceIdToValidations < ActiveRecord::Migration
  def change
    add_column :validations, :device_id, :integer
    add_index :validations,:device_id
  end
end
