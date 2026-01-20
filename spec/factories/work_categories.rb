# frozen_string_literal: true

FactoryBot.define do
  factory :work_category do
    association :work
    association :category
  end
end
