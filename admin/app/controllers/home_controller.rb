class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    if authenticated?
      @rooms = policy_scope(Room, policy_scope_class: RoomPolicy::Scope).limit(6)
    else
      @rooms = []
    end
  end
end
