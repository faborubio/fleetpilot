# Reconciles and dispatches alerts for a single account.
class AccountAlertsJob < ApplicationJob
  queue_as :default

  def perform(account)
    Alerts::Scanner.call(account)
    Alerts::Dispatcher.call(account)
  end
end
