module Habits::ItemsHelper
  def habit_card_classes(item)
    base = "habit-card rounded-2xl p-6 shadow-sm relative overflow-hidden transition hover:shadow-md"

    status = item.habit? ? item.today_log_status : item.status
    style = case status
    when "draft" then "bg-gray-100"
    when "complete" then "bg-green-200"
    when "overdue", "skipped" then "bg-red-200"
    else "bg-white border border-gray-100"
    end

    "#{base} #{style}"
  end

  def all_habits_lists_for_dropdown
    system_user = User.system_user
    shared_lists = Habits::List.where(user: system_user)
    shared_list_names = shared_lists.pluck(:name)
    user_lists = Habits::List.where(user: current_user).where.not(name: shared_list_names)
    Habits::List.where(id: (user_lists.pluck(:id) + shared_lists.pluck(:id))).order(:name)
  end

  def tag_options_for_user
    shared_tags = Habits::Tag.where(shared: true)
    shared_tag_names = shared_tags.pluck(:name)
    user_tags = Habits::Tag.joins(items: { list: :user }).where(habits_lists: { user_id: current_user.id }).where.not(name: shared_tag_names)
    tags = shared_tags + user_tags
    tags.uniq.sort_by(&:name).map { |t| [ t.name, t.id ] }
  end
end
