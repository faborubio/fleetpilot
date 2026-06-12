class CreateServiceRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :service_records do |t|
      t.references :account, null: false, foreign_key: true
      t.references :vehicle, null: false, foreign_key: true
      t.integer :category, null: false, default: 0
      t.date :performed_on, null: false
      t.integer :odometer
      t.integer :cost_cents
      t.string :vendor
      t.text :notes

      t.timestamps
    end
    add_index :service_records, [ :vehicle_id, :performed_on ]
  end
end
