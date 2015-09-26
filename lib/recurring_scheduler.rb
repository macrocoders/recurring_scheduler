require "recurring_scheduler/engine"
require "ice_cube"

module RecurringScheduler
  class << self
    def included(base)
      base.extend(ClassMethods)
    end
  end

  module ClassMethods
    attr_reader :recurring_action

    def assign_recurring_action(action)
      @recurring_action = action
    end
  end
end

class ActiveRecord::Base
  include RecurringScheduler
end
