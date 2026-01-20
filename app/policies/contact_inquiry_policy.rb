# frozen_string_literal: true

class ContactInquiryPolicy < ApplicationPolicy
  # Contact inquiries are admin-only for viewing/managing
  # Anyone can create (submit) a contact inquiry

  def index?
    admin?
  end

  def show?
    admin?
  end

  def create?
    true # Anyone can submit a contact form
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  def mark_responded?
    admin?
  end

  def archive?
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.none
      end
    end
  end
end
