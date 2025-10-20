class Habits::ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [ :edit, :update, :mark_complete ]

  def new
    @item = Habits::Item.new
  end

  def create
    @item = Habits::Item.new(item_params)
    @item.days_mask = @item.calculate_days_mask(params[:habits_item][:custom_days])
    @item.save
  end

  def edit
  end

  def update
    @item.assign_attributes(item_params)
    @item.days_mask = @item.calculate_days_mask(params[:habits_item][:custom_days])
    @save_success = @item.save
  end

  def mark_complete
    @item.update(status: Habits::Item.statuses[:complete])
  end

  private

  def set_item
    @item = Habits::Item.find(params[:id])
  end

  def item_params
    params.require(:habits_item).permit(:name, :list_id, :item_type, :frequency, :target_value, tag_ids: [])
  end
end
