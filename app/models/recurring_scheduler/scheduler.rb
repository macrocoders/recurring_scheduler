module RecurringScheduler
  class Scheduler < ActiveRecord::Base
    self.table_name = 'recurring_schedulers'

    # before_destroy :destroy_delayed_jobs

    belongs_to :schedulable, polymorphic: true

    validates :schedule_yaml, presence: true

    def schedule
      IceCube::Schedule.from_yaml schedule_yaml
    end

    def schedule_action
      if next_occurrence
        delay(run_at: next_occurrence, scheduler_id: id).process_schedule
      end
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

    def destroy_delayed_jobs
      Delayed::Job.where(scheduler_id: id).destroy_all
    end
  end
end
