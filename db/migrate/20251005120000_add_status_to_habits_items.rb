class AddStatusToHabitsItems < ActiveRecord::Migration[7.0]
  def change
    add_column :habits_items, :status, :integer, default: 0, null: false
  end
end
