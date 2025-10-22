class CreateHabitsLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :habits_logs do |t|
      t.references :item, null: false, foreign_key: { to_table: :habits_items }, index: true
      t.date :log_date, null: false
      t.integer :status, null: false, default: 0
      t.text :note

      t.timestamps
    end
  end
end
