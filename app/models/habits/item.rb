# == Schema Information
#
# Table name: habits_items
#
#  id          :bigint           not null, primary key
#  archived_at :datetime
#  data        :jsonb            not null
#  days_mask   :integer
#  due_on      :datetime
#  frequency   :integer          default("daily"), not null
#  item_type   :integer          default("habit"), not null
#  name        :string           not null
#  position    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  list_id     :bigint           not null
#
# Indexes
#
#  index_habits_items_on_list_id  (list_id)
#
# Foreign Keys
#
#  fk_rails_...  (list_id => habits_lists.id)
#
class Habits::Item < ApplicationRecord
  store_attribute :data, :target_value, :integer, default: 0
  store_attribute :data, :target_unit, :string, default: nil
  store_attribute :data, :duration_minutes, :integer, default: 0

  belongs_to :lists, class_name: "Habits::List"

  has_many :item_tags, class_name: "Habits::ItemTag", dependent: :destroy
  has_many :tags, through: :item_tags, class_name: "Habits::Tag"

  enum :item_type, { habit: 0, todo: 1 }
  enum :frequency, { daily: 0, weekly: 1, custom: 2 }

  validates :name, presence: true
end
