class User < ApplicationRecord
  PASSWORD_RESET_TOKEN_EXPIRATION = 20.minutes
  EMAIL_CONFIRMATION_TOKEN_EXPIRATION = 24.hours

  has_secure_password reset_token: { expires_in: PASSWORD_RESET_TOKEN_EXPIRATION }
  has_many :sessions, dependent: :destroy
  has_many :rooms, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  generates_token_for :email_confirmation, expires_in: EMAIL_CONFIRMATION_TOKEN_EXPIRATION do
    email_address
  end

  validates :email_address, presence: true,
                            uniqueness: { case_sensitive: false },
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, allow_nil: true

  def email_confirmation_token
    self.generate_token_for(:email_confirmation)
  end

  def email_confirmation_token_expires_in
    EMAIL_CONFIRMATION_TOKEN_EXPIRATION
  end

  def confirmed?
    confirmed_at.present?
  end

  def confirm!
    update(confirmed_at: Time.current)
  end
end
