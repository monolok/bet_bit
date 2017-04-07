# Preview all emails at http://localhost:3000/rails/mailers/contact_mailer
class ContactMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/contact_mailer/send_contact
  def send_contact
  	#@subject = "subject test"
  	@text = "testing text"
    ContactMailer.send_contact(@text)
  end

end
