# frozen_string_literal: true

Fabricator(:account_category_notification) do
  account { Fabricate.build(:account) }
  category { Fabricate.build(:category) }
end
