# frozen_string_literal: true

class CommissionPolicy < ApplicationPolicy
  # Customers can only view their own commissions
  # Admins can view all commissions
  def index?
    logged_in?
  end

  def show?
    admin? || owns_record?
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  def transition?
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      elsif user
        scope.where(user_id: user.id)
      else
        scope.none
      end
    end
  end

  private

  def owns_record?
    record.user_id == user&.id
  end
end
