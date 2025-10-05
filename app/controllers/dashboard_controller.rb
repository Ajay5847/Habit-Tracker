class DashboardController < ApplicationController
  def index
    @user = User.last
    @habits_lists = @user.habits_lists
    @habits = @habits_lists.first.items
  end
end
