class ChangeName < ActiveRecord::Migration
  def change
    rename_column :validations,:valid,:expired
  end
end
