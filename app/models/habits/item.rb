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
#  status      :integer          default("draft"), not null
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
  DAYS = %w[mon tue wed thu fri sat sun].freeze

  store_attribute :data, :target_value, :integer, default: 0
  store_attribute :data, :target_unit, :string, default: nil
  store_attribute :data, :duration_minutes, :integer, default: 0

  belongs_to :list, class_name: "Habits::List"

  has_many :item_tags, class_name: "Habits::ItemTag", dependent: :destroy
  has_many :tags, through: :item_tags, class_name: "Habits::Tag"

  enum :item_type, { habit: 0, todo: 1 }
  enum :frequency, { daily: 0, weekly: 1, custom: 2 }
  enum :status, { draft: 0, incomplete: 1, complete: 2, overdue: 3 }

  validates :name, presence: true

  before_save :sanitize_name

  scope :today, -> { where(created_at: Date.today.all_day) }

  def selected_days
    return [] if days_mask.blank? || days_mask.zero?

    DAYS.each_with_index.map { |day, i| day if (days_mask & (1 << i)) != 0 }.compact
  end

  def calculate_days_mask(custom_days)
    return unless custom?
    return 0 if custom_days.blank?

    days = Array(custom_days).flat_map { |d| d.split(",") }.map(&:strip).map(&:downcase)
    days.sum { |day| 1 << DAYS.index(day) if DAYS.include?(day) }.to_i
  end

private

  def sanitize_name
    self.name = name.strip
  end
end
