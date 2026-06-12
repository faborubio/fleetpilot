class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "alerts@fleetpilot.app")
  layout "mailer"
end
