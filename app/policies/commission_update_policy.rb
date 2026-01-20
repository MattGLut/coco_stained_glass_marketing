# frozen_string_literal: true

class CommissionUpdatePolicy < ApplicationPolicy
  # Commission updates follow the parent commission's access rules
  # Only admins can create/edit/delete updates
  # Customers can view updates marked as visible_to_customer

  def show?
    admin? || (owns_commission? && record.visible_to_customer?)
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

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      elsif user
        # Customers only see updates for their commissions that are visible to them
        scope.joins(:commission)
             .where(commissions: { user_id: user.id })
             .where(visible_to_customer: true)
      else
        scope.none
      end
    end
  end

  private

  def owns_commission?
    record.commission&.user_id == user&.id
  end
end
