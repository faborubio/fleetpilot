class CreateAlerts < ActiveRecord::Migration[8.1]
  def change
    create_table :alerts do |t|
      t.references :account, null: false, foreign_key: true
      t.references :alertable, polymorphic: true, null: false
      t.integer :category, null: false, default: 0
      t.integer :severity, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.string :message, null: false
      t.date :due_on

      t.timestamps
    end
    # The scanner enforces "one open alert per source+category" in code; this
    # index just makes the per-source lookup fast.
    add_index :alerts, [ :alertable_type, :alertable_id, :category ],
              name: "index_alerts_on_source_and_category"
    add_index :alerts, [ :account_id, :status ]
  end
end
