class AddTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :initial_token, :string
    add_column :users, :seeder, :boolean
  end
end
