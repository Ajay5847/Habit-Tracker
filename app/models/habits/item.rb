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
  store_attribute :data, :current_streak, :integer, default: 0
  store_attribute :data, :longest_streak, :integer, default: 0

  belongs_to :list, class_name: "Habits::List"

  has_many :item_tags, class_name: "Habits::ItemTag", dependent: :destroy
  has_many :tags, through: :item_tags, class_name: "Habits::Tag"
  has_many :logs, class_name: "Habits::Log", dependent: :destroy

  enum :item_type, { habit: 0, todo: 1 }
  enum :frequency, { daily: 0, weekly: 1, custom: 2 }
  enum :status, { draft: 0, complete: 1, overdue: 2 }

  validates :name, presence: true

  before_save :sanitize_name

  def show_today?
    return true if [ :daily, :weekly ].include?(frequency.to_sym)

    selected_days&.include?(Date.current.strftime("%a").downcase)
  end

  def completed_today?
    if habit?
      logs.exists?(log_date: Date.current, status: Habits::Log.statuses[:complete])
    else
      complete?
    end
  end

  def today_log_status
    logs.find_by(log_date: Date.current)&.status || "incomplete"
  end

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

  def update_streaks!
    completed_dates = logs.complete.order(:log_date).pluck(:log_date)
    return update!(current_streak: 0, longest_streak: 0) if completed_dates.empty?

    longest = 1
    current = 1

    completed_dates.each_cons(2) do |a, b|
      if b == a + 1
        current += 1
        longest = [ longest, current ].max
      else
        current = 1
      end
    end

    # If last log was yesterday or today, keep current streak
    last_date = completed_dates.last
    current_streak = last_date >= Date.yesterday ? current : 0
    update!(current_streak: current_streak, longest_streak: longest)
  end

private

  def sanitize_name
    self.name = name.strip
  end
end
