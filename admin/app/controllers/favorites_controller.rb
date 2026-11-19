class FavoritesController < ApplicationController
  before_action :set_room

  def create
    current_user.favorites.find_or_create_by!(room: @room)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @room, notice: t("favorites.added") }
    end
  end

  def destroy
    current_user.favorites.find_by(room: @room)&.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @room, notice: t("favorites.removed") }
    end
  end

  private

  def set_room
    @room = Room.find(params[:room_id])
  end
end
