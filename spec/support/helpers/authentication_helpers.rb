# frozen_string_literal: true

module AuthenticationHelpers
  def sign_in_as(user)
    sign_in user
  end

  def sign_in_as_admin
    admin = create(:user, :admin)
    sign_in admin
    admin
  end

  def sign_in_as_customer
    customer = create(:user, :customer)
    sign_in customer
    customer
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
  config.include AuthenticationHelpers, type: :system
end
