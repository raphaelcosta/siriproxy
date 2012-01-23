class CreateAccessHistories < ActiveRecord::Migration
  def change
    create_table :access_histories do |t|
      t.references :device
      t.string :ip

      t.timestamps
    end
    add_index :access_histories, :device_id
  end
end
