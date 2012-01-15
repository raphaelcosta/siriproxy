class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :speechid
      t.string :assitantid
      t.references :user
      t.string :token

      t.timestamps
    end
    add_index :devices, :user_id
  end
end
