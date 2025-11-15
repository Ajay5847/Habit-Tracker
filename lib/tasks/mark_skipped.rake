namespace :habits do
  desc "Mark incomplete habits as skipped for today"
  task mark_incomplete_as_skipped: :environment do
    begin
      Habits::MarkIncompleteAsSkippedJob.perform_now
      puts "[#{Time.current}] mark_incomplete_as_skipped: success"
    rescue => e
      puts "[#{Time.current}] mark_incomplete_as_skipped: ERROR #{e.class} #{e.message}"
      puts e.backtrace.join("\n")
      raise
    end
  end
end
