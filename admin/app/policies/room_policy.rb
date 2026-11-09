# frozen_string_literal: true

class RoomPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    record.is_public? || user.present?
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

  def owner?
    user.present? && record.respond_to?(:user_id) && record.user_id.present? && record.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.present?
        scope.where(user_id: user.id)
      else
        scope.none
      end
    end
  end
end
