class CreateRenewals < ActiveRecord::Migration[8.1]
  def change
    create_table :renewals do |t|
      t.references :account, null: false, foreign_key: true
      t.references :vehicle, null: false, foreign_key: true
      t.integer :kind, null: false, default: 0
      t.date :expires_on, null: false
      t.string :notes

      t.timestamps
    end
    add_index :renewals, [ :vehicle_id, :kind ], unique: true
    add_index :renewals, :expires_on
  end
end
