class Habits::ItemsController < ApplicationController
  before_action :authenticate_user!

  def new
    @item = Habits::Item.new
  end
end
