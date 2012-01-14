class RenameUserId < ActiveRecord::Migration
  def change
    rename_column :validations,:user_id_id , :user_id
  end
end
