module RecurringScheduler
  class TransformSchedule
    def initialize(schedule_from_params)
      @schedule_from_params = schedule_from_params
    end

    def perform
      IceCube::Schedule.from_hash(schedule_hash)
    end

    private

    def schedule_hash
      JSON.parse(@schedule_from_params)
    end
  end
end
