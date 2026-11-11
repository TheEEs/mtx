class Room < ApplicationRecord
    has_secure_password validations: false

    belongs_to :user, optional: true
    include Hashid::Rails
    validates :name, :description, :owner, :valid_to, :valid_from, presence: true
    validates :name, uniqueness: true
    validate :valid_from_must_be_less_than_valid_to
    validates :stream_id, uniqueness: true, unless: -> { stream_id.blank? }

    before_validation :clear_password_if_public

    scope :public_rooms, -> { where(is_public: true) }
    scope :private_rooms, -> { where(is_public: false) }

    def password_protected?
      !is_public? && password_digest.present?
    end

    def expired?
        valid_to.present? && Time.current > valid_to
    end

    def not_started?
        valid_from.present? && Time.current < valid_from
    end

    def available?
        !expired? && !not_started?
    end

    def jwt
        payload = {
            exp: self.valid_to.to_i,
            nbf: self.valid_from.to_i,
            id: self.hashid,
            name: self.name
          # updated_at: self.updated_at.to_i
        }
        JWT.encode(payload, Rails.application.credentials.secret_key_base, "HS512")
    end

    def toggle_stream
        res = HTTParty.post(
          "http://mediamtx:7498/v3/webrtcsessions/kick/#{stream_id}"
        )
        res.code == 200
    end

    private
    def clear_password_if_public
      self.password_digest = nil if is_public?
    end

    def valid_from_must_be_less_than_valid_to
        if (valid_to && valid_from) and valid_from >= valid_to
            formatted_time = I18n.l(valid_to, format: :long)
            errors.add(:valid_from, I18n.t("errors.messages.less_than", count: formatted_time))
        end
    end
end
