# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  # Only admins can manage users
  # Users can view/edit their own profile (handled by Devise)

  def index?
    admin?
  end

  def show?
    admin? || record == user
  end

  def create?
    admin?
  end

  def update?
    admin? || record == user
  end

  def destroy?
    # Admins can delete users, but not themselves
    admin? && record != user
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      elsif user
        scope.where(id: user.id)
      else
        scope.none
      end
    end
  end
end
