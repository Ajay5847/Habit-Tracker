class DashboardController < ApplicationController
  def index
    if user_signed_in?
      habits = current_user.habit_items.select(&:show_today?)

      @in_progress_habits = habits.reject(&:completed_today?)
      @completed_habits   = habits.select(&:completed_today?)

      render :welcome
    else
      render :index
    end
  end
end
