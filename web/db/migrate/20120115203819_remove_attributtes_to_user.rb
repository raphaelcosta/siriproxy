class RemoveAttributtesToUser < ActiveRecord::Migration
  def change
    remove_column :users,:speech_id
    remove_column :users,:assistant_id
    remove_column :users,:initial_token
    remove_column :users,:confirmed_at
    remove_column :validations,:user_id
  end
end
