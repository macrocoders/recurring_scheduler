module RecurringScheduler
  module RecurringSchedulerHelper
    def schedule_in_words(schedule)
      rule_in_words = schedule.to_s
      time = schedule.start_time.strftime '%l:%M %p'
      "#{rule_in_words} at #{time}"
    end
  end
end
