class Room < ApplicationRecord
    include Hashid::Rails
    validates :name, :description, :owner, :valid_to, :valid_from, presence: true
    validates :name, uniqueness: true
    validate :valid_from_must_be_less_than_valid_to
    validates :stream_id, uniqueness: true, unless: -> { stream_id.blank? }
    def jwt
        payload = {
            exp: self.valid_to.to_i,
            nbf: self.valid_from.to_i,
            id: self.hashid,
            name: self.name,
            #updated_at: self.updated_at.to_i
        }
        JWT.encode(payload, Rails.application.credentials.key, "HS512")
    end


    def toggle_stream
        res = HTTParty.post(
          "http://mediamtx:7498/v3/webrtcsessions/kick/#{stream_id}"
        )
        return res.code == 200
    end


    private 
    def valid_from_must_be_less_than_valid_to
        if (valid_to && valid_from) and valid_from >= valid_to
            formatted_time = I18n.l(valid_to, format: :long)
            errors.add(:valid_from, I18n.t("errors.messages.less_than", count: formatted_time))
        end
    end
end
