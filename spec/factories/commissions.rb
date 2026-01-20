# frozen_string_literal: true

FactoryBot.define do
  factory :commission do
    association :user, factory: [:user, :customer]
    title { Faker::Lorem.sentence(word_count: 4) }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    customer_notes { Faker::Lorem.paragraph(sentence_count: 2) }
    dimensions { "#{rand(12..48)}\" x #{rand(12..48)}\"" }
    location { Faker::Address.full_address }
    status { "inquiry" }

    trait :with_quote do
      status { "quoted" }
      estimated_price { Faker::Commerce.price(range: 500..5000.0) }
      estimated_start_date { 2.weeks.from_now.to_date }
      estimated_completion_date { 2.months.from_now.to_date }
    end

    trait :accepted do
      status { "accepted" }
      estimated_price { Faker::Commerce.price(range: 500..5000.0) }
      deposit_amount { |c| c.estimated_price * 0.25 }
    end

    trait :deposit_received do
      status { "deposit_received" }
      estimated_price { Faker::Commerce.price(range: 500..5000.0) }
      deposit_amount { |c| c.estimated_price * 0.25 }
      deposit_paid { true }
      deposit_paid_at { Date.current }
    end

    trait :in_progress do
      status { "in_progress" }
      estimated_price { Faker::Commerce.price(range: 500..5000.0) }
      deposit_amount { |c| c.estimated_price * 0.25 }
      deposit_paid { true }
      deposit_paid_at { 1.week.ago.to_date }
      actual_start_date { 3.days.ago.to_date }
      estimated_completion_date { 1.month.from_now.to_date }
    end

    trait :completed do
      status { "completed" }
      estimated_price { Faker::Commerce.price(range: 500..5000.0) }
      final_price { |c| c.estimated_price }
      deposit_paid { true }
      actual_start_date { 2.months.ago.to_date }
      actual_completion_date { Date.current }
    end

    trait :delivered do
      status { "delivered" }
      estimated_price { Faker::Commerce.price(range: 500..5000.0) }
      final_price { |c| c.estimated_price }
      deposit_paid { true }
      actual_start_date { 3.months.ago.to_date }
      actual_completion_date { 1.week.ago.to_date }
      delivered_at { Date.current }
    end

    trait :cancelled do
      status { "cancelled" }
    end

    trait :with_updates do
      transient do
        updates_count { 3 }
      end

      after(:create) do |commission, evaluator|
        create_list(:commission_update, evaluator.updates_count, commission: commission)
      end
    end
  end
end
