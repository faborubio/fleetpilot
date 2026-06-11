class CreateAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :assignments do |t|
      t.references :account, null: false, foreign_key: true
      t.references :vehicle, null: false, foreign_key: true
      t.references :driver, null: false, foreign_key: true
      t.date :started_on, null: false
      t.date :ended_on

      t.timestamps
    end
    add_index :assignments, [ :vehicle_id, :started_on ]
    add_index :assignments, [ :driver_id, :started_on ]
  end
end
