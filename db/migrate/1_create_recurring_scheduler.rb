class CreateRecurringScheduler < ActiveRecord::Migration
  def change
    create_table :recurring_schedulers do |t|
      t.text :schedule_yaml
      t.references :schedulable, polymorphic: true

      t.timestamps
    end
  end
end
