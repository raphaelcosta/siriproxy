class AddUdidToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :udid, :string

  end
end
