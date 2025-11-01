class Habits::MarkIncompleteAsSkippedJob < ApplicationJob
  queue_as :default

  def perform
    Habits::Item.habit.select(&:show_today?).each do |item|
      log = item.logs.find_or_create_by(log_date: Date.current)

      if log.persisted? && !log.complete?
        log.update(status: Habits::Log.statuses[:skipped])
      end
    end
  end
end
