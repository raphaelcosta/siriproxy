class ChangeNameAssistantIdOfDevices < ActiveRecord::Migration
  def change
    rename_column :devices, :assitantid,:assistandid
  end
end
