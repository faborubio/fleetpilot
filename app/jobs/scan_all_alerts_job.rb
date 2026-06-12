# Fans out the daily alert scan: one AccountAlertsJob per account, so a slow or
# failing account does not block the others.
class ScanAllAlertsJob < ApplicationJob
  queue_as :default

  def perform
    Account.find_each do |account|
      AccountAlertsJob.perform_later(account)
    end
  end
end
