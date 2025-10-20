class DashboardController < ApplicationController
  def index
    if user_signed_in?
      @in_progress_habits = current_user.habit_items.where.not(status: Habits::Item.statuses[:complete]).today.order(created_at: :asc)
      @completed_habits = current_user.habit_items.complete.today.order(updated_at: :desc)

      render :welcome
    else
      render :index
    end
  end
end
