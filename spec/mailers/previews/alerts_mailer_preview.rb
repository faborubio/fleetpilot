# Preview all emails at http://localhost:3000/rails/mailers/alerts_mailer
class AlertsMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/alerts_mailer/digest
  def digest
    account = Account.first
    user = account.users.first
    AlertsMailer.digest(user, account.alerts.active.limit(10).pluck(:id))
  end
end
