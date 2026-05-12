json.extract! room, :id, :name, :owner, :description, :valid_from, :valid_to, :created_at, :updated_at
json.url room_url(room, format: :json)
