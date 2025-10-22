# == Schema Information
#
# Table name: habits_logs
#
#  id         :bigint           not null, primary key
#  log_date   :date             not null
#  note       :text
#  status     :integer          default("draft"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  item_id    :bigint           not null
#
# Indexes
#
#  index_habits_logs_on_item_id  (item_id)
#
# Foreign Keys
#
#  fk_rails_...  (item_id => habits_items.id)
#
class Habits::Log < ApplicationRecord
  belongs_to :item, class_name: "Habits::Item"

  enum :status, { draft: 0, complete: 1, skipped: 2 }, validate: true

  validates :log_date, presence: true, uniqueness: { scope: :item_id }
end
