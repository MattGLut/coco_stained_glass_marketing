# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    confirmed_at { Time.current }
    role { :customer }

    trait :customer do
      role { :customer }
    end

    trait :admin do
      role { :admin }
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :locked do
      locked_at { Time.current }
      failed_attempts { 10 }
    end

    trait :with_phone do
      phone { Faker::PhoneNumber.phone_number }
    end
  end
end
