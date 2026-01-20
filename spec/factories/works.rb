# frozen_string_literal: true

FactoryBot.define do
  factory :work do
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    dimensions { "#{rand(12..48)}\" x #{rand(12..48)}\"" }
    medium { ["Stained glass, lead came", "Stained glass, copper foil", "Fused glass"].sample }
    year_created { rand(2015..Date.current.year) }
    featured { false }
    published { true }
    position { 0 }

    trait :featured do
      featured { true }
    end

    trait :draft do
      published { false }
    end

    trait :published do
      published { true }
    end

    trait :with_images do
      after(:build) do |work|
        work.images.attach(
          io: StringIO.new("fake image content"),
          filename: "test_image.jpg",
          content_type: "image/jpeg"
        )
      end
    end

    trait :with_categories do
      transient do
        category_count { 2 }
      end

      after(:create) do |work, evaluator|
        categories = create_list(:category, evaluator.category_count)
        work.categories << categories
      end
    end
  end
end
