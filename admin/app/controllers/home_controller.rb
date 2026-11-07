class HomeController < ApplicationController
  allow_unauthenticated_access
  def index
    @rooms = Room.order(created_at: :desc).limit(6)
  end
end
