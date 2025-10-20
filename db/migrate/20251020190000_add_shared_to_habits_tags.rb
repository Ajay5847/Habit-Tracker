class AddSharedToHabitsTags < ActiveRecord::Migration[7.0]
  def change
    add_column :habits_tags, :shared, :boolean, default: false, null: false
  end
end
