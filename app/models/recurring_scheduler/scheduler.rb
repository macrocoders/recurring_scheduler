module RecurringScheduler
  class Scheduler < ActiveRecord::Base
    self.table_name = 'recurring_schedulers'

    after_save :schedule_action

    belongs_to :schedulable, polymorphic: true

    validates :schedule_yaml, presence: true

    def schedule
      IceCube::Schedule.from_yaml schedule_yaml
    end

    def schedule_action
      next_occurrence = schedule.next_occurrence

      ProcessScheduleJob.set(wait_until: next_occurrence).perform_later(self) if next_occurrence
    end

    def process_action
      schedulable.send(action)
    end

    def process_schedule
      schedule_action
      process_action
    end

    def rrule
      schedule.rrules.first
    end

    def occurs_on?(date)
      schedule.occurs_on?(date)
    end

    private

    def action
      schedulable.class.recurring_action
    end
  end
end
