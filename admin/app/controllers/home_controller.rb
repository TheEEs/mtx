class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    if authenticated?
      @rooms = policy_scope(Room, policy_scope_class: RoomPolicy::Scope)
    else
      @rooms = Room.public_rooms.order(created_at: :desc).limit(6)
    end
  end
end
