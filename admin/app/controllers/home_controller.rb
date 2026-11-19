class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    if authenticated?
      fav_ids = current_user.favorite_room_ids
      base_scope = if fav_ids.any?
        Room.where("rooms.is_public = ? OR rooms.user_id = ? OR rooms.id IN (?)", true, current_user.id, fav_ids)
      else
        Room.where("rooms.is_public = ? OR rooms.user_id = ?", true, current_user.id)
      end

      if fav_ids.any?
        sanitized_ids = fav_ids.map(&:to_i).join(",")
        @rooms = base_scope.order(Arel.sql("CASE WHEN rooms.id IN (#{sanitized_ids}) THEN 0 ELSE 1 END"), created_at: :desc).limit(6)
      else
        @rooms = base_scope.order(created_at: :desc).limit(6)
      end
    else
      @rooms = Room.public_rooms.order(created_at: :desc).limit(6)
    end
  end
end
