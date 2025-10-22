class Habits::ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [ :edit, :update, :mark_complete, :destroy ]

  def new
    @item = Habits::Item.new
  end

  def create
    resolved_list_id = resolve_user_list_id(item_params[:list_id])
    params_with_user_list = item_params.merge(list_id: resolved_list_id)
    @item = Habits::Item.new(params_with_user_list)
    @item.days_mask = @item.calculate_days_mask(params[:habits_item][:custom_days])
    @item.save

    tag_values = params[:habits_item][:tag_ids] || []

    if tag_values.present?
      tag_ids = tag_values.reject(&:blank?).map do |tag_param|
        if tag_param.to_i.positive?
          tag_param.to_i
        else
          @item.tags.find_or_create_by!(name: tag_param.strip).id
        end
      end

      @item.update(tag_ids: tag_ids)
    end
  end

  def edit
  end

  def update
    resolved_list_id = resolve_user_list_id(item_params[:list_id])
    params_with_user_list = item_params.merge(list_id: resolved_list_id)
    @item.assign_attributes(params_with_user_list)
    @item.days_mask = @item.calculate_days_mask(params[:habits_item][:custom_days])
    @save_success = @item.save
  end

  def mark_complete
    if @item.habit?
      @item.logs.create!(log_date: Date.current, status: Habits::Log.statuses[:complete])
    elsif @item.todo?
      @item.update(status: Habits::Item.statuses[:complete])
    end
  end

  def destroy
    @item.destroy
  end

  private

  def set_item
    @item = Habits::Item.find(params[:id])
  end

  def item_params
    params.require(:habits_item).permit(:name, :list_id, :item_type, :frequency, :target_value)
  end

  def resolve_user_list_id(selected_list_id)
    list = Habits::List.find_by(id: selected_list_id)
    return Habits::List.create!(user: current_user, name: selected_list_id).id unless list

    # If it's a system-owned list, clone for current user
    return Habits::List.find_or_create_by!(user: current_user, name: list.name) do |l|
            l.description = list.description
          end.id if list.user == User.system_user

    list.id
  end
end
