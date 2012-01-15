class RenameColumnAgain < ActiveRecord::Migration
  def change
    rename_column :devices, :assistandid,:assistantid
  end
end
