# Preview all emails at http://localhost:3000/rails/mailers/users_mailer
class UsersMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/users_mailer/confirmation
  def confirmation
    UsersMailer.confirmation(User.take || User.new(email_address: "test@example.com"))
  end
end
