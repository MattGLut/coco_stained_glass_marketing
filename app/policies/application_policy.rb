# frozen_string_literal: true

# Base policy class for Pundit authorization
# All policies should inherit from this class
#
# Default behavior: deny all actions (secure by default)
# Subclasses should override methods to grant access
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # Default: deny all actions (secure by default)
  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  # ============================================================================
  # Helper methods available to all policies
  # ============================================================================

  def admin?
    user&.admin?
  end

  def customer?
    user&.customer?
  end

  def logged_in?
    user.present?
  end

  # Check if record belongs to current user (for models with user_id)
  def owned_by_user?
    record.respond_to?(:user_id) && record.user_id == user&.id
  end

  # ============================================================================
  # Base Scope class
  # ============================================================================
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    # Default: return nothing (secure by default)
    # Subclasses should override to return appropriate records
    def resolve
      scope.none
    end

    private

    def admin?
      user&.admin?
    end

    def customer?
      user&.customer?
    end

    def logged_in?
      user.present?
    end
  end
end
