class CreateHabitsItems < ActiveRecord::Migration[8.0]
  def change
    create_table :habits_items do |t|
      t.string     :name, null: false
      t.integer    :item_type, null: false, default: 0
      t.integer    :frequency, null: false, default: 0
      t.integer    :days_mask
      t.datetime   :due_on
      t.integer    :position
      t.datetime   :archived_at
      t.jsonb      :data, null: false, default: {}
      t.references :list, null: false, foreign_key: { to_table: :habits_lists }, index: true

      t.timestamps
    end
  end
end
