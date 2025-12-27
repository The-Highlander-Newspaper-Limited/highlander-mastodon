# frozen_string_literal: true

Fabricator(:account_category_filter) do
  account { Fabricate.build(:account) }
  category { Fabricate.build(:category) }
end
