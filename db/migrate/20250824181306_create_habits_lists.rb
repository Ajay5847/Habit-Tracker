class CreateHabitsLists < ActiveRecord::Migration[8.0]
  def change
    create_table :habits_lists do |t|
      t.string :name, null: false
      t.text :description
      t.integer :position
      t.datetime :archived_at
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
