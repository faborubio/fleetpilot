class AddNotificationPreferencesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :notify_by_email, :boolean, null: false, default: true
    add_column :users, :notify_by_sms, :boolean, null: false, default: false
  end
end
