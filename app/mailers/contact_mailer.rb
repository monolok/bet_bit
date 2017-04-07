class ContactMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.contact_mailer.send_contact.subject
  #
  def send_contact(subject, text)
    @subject = subject
    @text = text

    mail to: "antoinebe35@gmail.com", subject: @subject
  end
end
