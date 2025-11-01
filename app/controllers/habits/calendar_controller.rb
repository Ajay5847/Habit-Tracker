class Habits::CalendarController < ApplicationController
  before_action :authenticate_user!
  before_action :set_date_range

  def index
    @habits = fetch_habits
    @stats = calculate_monthly_stats

    respond_to do |format|
      format.html
      format.json do
        render json: {
          habits: serialize_habits,
          stats: @stats,
          current_date: @date
        }
      end
    end
  end

  private

  def set_date_range
    @year = params[:year]&.to_i || Date.current.year
    @month = params[:month]&.to_i || Date.current.month
    @date = Date.new(@year, @month, 1)
    @start_date = @date.beginning_of_month
    @end_date = @date.end_of_month
  end

  def fetch_habits
    current_user.habit_items.habit.where(archived_at: nil).where("habits_items.created_at <= ?", @end_date.end_of_day).includes(:logs).order(:position)
  end

  def calculate_monthly_stats
    return empty_stats if @habits.empty?

    total_days = @end_date.day
    total_possible = @habits.count * total_days
    total_completed = Habits::Log.where(item: @habits).where(log_date: @start_date..@end_date).where(status: :complete).count
    completion_rate = total_possible.positive? ? (total_completed.to_f / total_possible * 100).round(0) : 0

    {
      completion_rate: completion_rate,
      best_streak: @habits.maximum("(data->>'longest_streak')::int") || 0,
      total_habits: @habits.count,
      total_completed: total_completed,
      total_possible: total_possible
    }
  end

  def empty_stats
    {
      completion_rate: 0,
      best_streak: 0,
      total_habits: 0,
      total_completed: 0,
      total_possible: 0
    }
  end

  def serialize_habits
    @habits.map do |habit|
      # Get all logs for this habit in the date range
      logs = habit.logs.where(log_date: @start_date..@end_date)

      # Group by status
      completed_dates = logs.where(status: :complete).pluck(:log_date).map(&:to_s)
      skipped_dates = logs.where(status: :skipped).pluck(:log_date).map(&:to_s)
      draft_dates = logs.where(status: :draft).pluck(:log_date).map(&:to_s)

      {
        id: habit.id,
        name: habit.name,
        color: generate_color_for_habit(habit),
        completions: completed_dates, # Keep for backward compatibility with dots
        skipped: skipped_dates,
        drafts: draft_dates,
        completion_count: completed_dates.count,
        total_days: @end_date.day,
        current_streak: habit.current_streak,
        longest_streak: habit.longest_streak
      }
    end
  end

  def generate_color_for_habit(habit)
    # Consistent color palette matching Tailwind theme
    colors = %w[#22C55E #0EA5E9 #F59E0B #3B82F6 #8B5CF6 #EC4899 #14B8A6 #F97316]
    colors[habit.id % colors.length]
  end
end
