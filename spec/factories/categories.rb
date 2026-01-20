# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    name { Faker::Lorem.unique.word.capitalize }
    description { Faker::Lorem.sentence }
    position { 0 }

    trait :with_works do
      transient do
        works_count { 3 }
      end

      after(:create) do |category, evaluator|
        works = create_list(:work, evaluator.works_count)
        category.works << works
      end
    end
  end
end
