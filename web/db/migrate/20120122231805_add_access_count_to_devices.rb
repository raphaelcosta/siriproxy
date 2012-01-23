class AddAccessCountToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :access_count, :integer, :default => 0

  end
end
