module Habits::ItemsHelper
  def habit_card_classes(item)
    base = "habit-card rounded-2xl p-6 shadow-sm relative overflow-hidden transition hover:shadow-md"
    style = case item.status
    when "draft" then "bg-gray-100"
    when "incomplete" then "bg-white border border-gray-100"
    when "complete" then "bg-green-200"
    when "overdue" then "bg-red-200"
    else "bg-white border border-gray-100"
    end
    "#{base} #{style}"
  end
end
