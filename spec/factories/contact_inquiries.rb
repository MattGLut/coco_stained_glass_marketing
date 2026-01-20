# frozen_string_literal: true

FactoryBot.define do
  factory :contact_inquiry do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    subject { Faker::Lorem.sentence(word_count: 4) }
    message { Faker::Lorem.paragraph(sentence_count: 3) }
    status { :pending }

    trait :responded do
      status { :responded }
      responded_at { Time.current }
    end

    trait :archived do
      status { :archived }
    end

    trait :with_notes do
      admin_notes { Faker::Lorem.paragraph(sentence_count: 2) }
    end
  end
end
