class DashboardController < ApplicationController
  def index
    if user_signed_in?
      @in_progress_habits = current_user.habit_items.where.not(status: Habits::Item.statuses[:complete]).order(:position)
      @completed_habits = current_user.habit_items.where(status: Habits::Item.statuses[:complete]).order(updated_at: :desc)

      render :welcome
    else
      render :index
    end
  end
end
