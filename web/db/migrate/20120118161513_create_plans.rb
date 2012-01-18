class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.decimal :price
      t.integer :months
      t.integer :devices

      t.timestamps
    end
  end
end
