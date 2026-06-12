class CreateMaintenanceSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :maintenance_schedules do |t|
      t.references :account, null: false, foreign_key: true
      t.references :vehicle, null: false, foreign_key: true
      t.integer :category, null: false, default: 0
      t.integer :interval_months
      t.integer :interval_miles
      t.date :last_performed_on
      t.integer :last_performed_odometer

      t.timestamps
    end
    add_index :maintenance_schedules, [ :vehicle_id, :category ], unique: true
  end
end
