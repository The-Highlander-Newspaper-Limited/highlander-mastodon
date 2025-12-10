# frozen_string_literal: true

Fabricator(:category) do
  name { sequence(:name) { |i| "Category #{i}" } }
  description { Faker::Lorem.paragraph }
  mandatory_for_readers false
end
