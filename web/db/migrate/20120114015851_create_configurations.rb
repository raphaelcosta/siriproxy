class CreateConfigurations < ActiveRecord::Migration
  def change
    create_table :configurations do |t|
      t.integer :active_connections

      t.timestamps
    end
  end
end
