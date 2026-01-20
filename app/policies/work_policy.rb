# frozen_string_literal: true

class WorkPolicy < ApplicationPolicy
  # Public can view published works
  # Admins can manage all works

  def index?
    true # Public gallery
  end

  def show?
    admin? || record.published?
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

  def publish?
    admin?
  end

  def unpublish?
    admin?
  end

  def feature?
    admin?
  end

  def unfeature?
    admin?
  end

  def remove_image?
    admin?
  end

  def update_positions?
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.published
      end
    end
  end
end
