class AddFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :speech_id, :string
    add_column :users, :assistant_id, :string
  end
end
