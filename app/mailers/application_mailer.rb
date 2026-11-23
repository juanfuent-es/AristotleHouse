class ApplicationMailer < ActionMailer::Base
  default from: -> { Rails.configuration.x.site.mail_from }
  layout "mailer"
end
