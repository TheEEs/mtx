# frozen_string_literal: true

class RoomPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    true
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    owner?
  end

  def edit?
    update?
  end

  def destroy?
    owner?
  end

  def toggle_stream?
    owner?
  end

  def unlock?
    user.present?
  end

  def owner?
    user.present? && record.respond_to?(:user_id) && record.user_id.present? && record.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.present?
        fav_ids = user.favorite_room_ids
        if fav_ids.any?
          scope.where("rooms.user_id = :user_id OR rooms.id IN (:fav_ids)", user_id: user.id, fav_ids: fav_ids).distinct
        else
          scope.where(user_id: user.id)
        end
      else
        scope.none
      end
    end
  end
end
