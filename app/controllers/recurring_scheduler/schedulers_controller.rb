module RecurringScheduler
  class SchedulersController < BaseController
    include RecurringSchedulerHelper

    def new
      @scheduler = Scheduler.new
      @schedule = IceCube::Schedule.new(Time.zone.now)
      @schedulable = find_schedulable
    end

    def edit
      @scheduler = Scheduler.find(params[:id])
      @schedule = @scheduler.schedule
    end

    def create
      @schedulable = find_schedulable
      schedule_yaml = TransformSchedule.new(params[:scheduler][:schedule]).perform.to_yaml

      @scheduler = Scheduler.new(
        schedule_yaml: schedule_yaml,
        schedulable: @schedulable
      )

      if @scheduler.save
        render 'update_schedule_information'
      else
        render json: FAILURE, status: :unprocessable_entity
      end
    end

    def update
      @scheduler = Scheduler.find(params[:id])
      @schedulable = @scheduler.schedulable
      schedule_yaml = TransformSchedule.new(params[:scheduler][:schedule]).perform.to_yaml

      if @scheduler.update_attributes(schedule_yaml: schedule_yaml)
        render 'update_schedule_information'
      else
        render json: FAILURE, status: :unprocessable_entity
      end
    end

    def destroy
      @scheduler = Scheduler.find(params[:id])
      @schedulable = @scheduler.schedulable

      if @scheduler.destroy
        @scheduler = nil
        render 'update_schedule_information'
      else
        render json: FAILURE, status: :unprocessable_entity
      end
    end

    def update_summary
      schedule = TransformSchedule.new(params[:schedule]).perform

      render text: schedule_in_words(schedule)
    end

    private

    def find_schedulable
      ar_models = ActiveRecord::Base.descendants
      klass = ar_models.find { |c| params["#{c.name.underscore}_id"] }
      klass.find(params["#{klass.name.underscore}_id"])
    end
  end
end
