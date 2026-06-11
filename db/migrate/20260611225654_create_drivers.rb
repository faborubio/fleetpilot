class CreateDrivers < ActiveRecord::Migration[8.1]
  def change
    create_table :drivers do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.string :license_number
      t.date :license_expires_on
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    add_index :drivers, [ :account_id, :status ]
  end
end
