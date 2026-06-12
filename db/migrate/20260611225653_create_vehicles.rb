class CreateVehicles < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicles do |t|
      t.references :account, null: false, foreign_key: true
      t.string :vin, null: false, limit: 17
      t.string :make
      t.string :model
      t.integer :year
      t.string :license_plate
      t.integer :status, null: false, default: 0
      t.integer :odometer, null: false, default: 0
      t.integer :fuel_type
      t.date :purchased_on
      t.integer :purchase_price_cents

      t.timestamps
    end
    add_index :vehicles, [ :account_id, :vin ], unique: true
    add_index :vehicles, [ :account_id, :status ]
  end
end
