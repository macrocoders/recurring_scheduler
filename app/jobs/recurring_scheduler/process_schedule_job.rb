module RecurringScheduler
  class ProcessScheduleJob < ActiveJob::Base
    queue_as :process_schedule_jobs

    def perform(scheduler)
      scheduler.process_schedule
    end
  end
end
