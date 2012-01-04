class CreateSeeders < ActiveRecord::Migration
  def change
    create_table :seeders do |t|
      t.string :name
      t.string :speech_id
      t.string :assistant_id

      t.timestamps
    end
  end
end
