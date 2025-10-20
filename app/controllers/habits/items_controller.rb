class Habits::ItemsController < ApplicationController
  before_action :authenticate_user!

  def new
    @item = Habits::Item.new
  end

  def create
    @item = Habits::Item.new(item_params)
    @item.days_mask = @item.calculate_days_mask(params[:habits_item][:custom_days])
    @item.save
  end

private

  def item_params
    params.require(:habits_item).permit(:name, :list_id, :item_type, :frequency, :target_value)
  end
end
