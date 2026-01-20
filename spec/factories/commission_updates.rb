# frozen_string_literal: true

FactoryBot.define do
  factory :commission_update do
    association :commission
    association :user, factory: [:user, :admin]
    title { Faker::Lorem.sentence(word_count: 4) }
    body { Faker::Lorem.paragraph(sentence_count: 3) }
    notify_customer { true }
    visible_to_customer { true }

    trait :internal do
      visible_to_customer { false }
      notify_customer { false }
    end

    trait :silent do
      notify_customer { false }
    end

    trait :with_images do
      after(:build) do |update|
        update.images.attach(
          io: StringIO.new("fake image content"),
          filename: "progress_image.jpg",
          content_type: "image/jpeg"
        )
      end
    end
  end
end
