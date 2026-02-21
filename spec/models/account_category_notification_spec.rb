# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountCategoryNotification do
  subject { Fabricate.build(:account_category_notification) }

  it { is_expected.to belong_to(:account).inverse_of(:account_category_notifications) }
  it { is_expected.to belong_to(:category).inverse_of(:account_category_notifications) }
  it { is_expected.to validate_uniqueness_of(:category_id).scoped_to(:account_id) }
end
