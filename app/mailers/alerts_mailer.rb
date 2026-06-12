class AlertsMailer < ApplicationMailer
  # Sends one user a digest of the given alerts. Takes alert IDs (not records)
  # so the mail is safe to enqueue and deliver later.
  def digest(user, alert_ids)
    @user = user
    @alerts = user.account.alerts.where(id: alert_ids).by_urgency
    return if @alerts.empty?

    mail to: user.email_address,
         subject: "FleetPilot: #{pluralize(@alerts.size, 'fleet alert')} need your attention"
  end

  private

  def pluralize(count, noun)
    ActionController::Base.helpers.pluralize(count, noun)
  end
end
