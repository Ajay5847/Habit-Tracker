class CreateHabitsItemTags < ActiveRecord::Migration[8.0]
  def change
    create_table :habits_item_tags do |t|
      t.references :item, null: false, foreign_key: { to_table: :habits_items }
      t.references :tag, null: false, foreign_key: { to_table: :habits_tags }
      
      t.timestamps
    end

    add_index :habits_item_tags, [:item_id, :tag_id], unique: true
  end
end
