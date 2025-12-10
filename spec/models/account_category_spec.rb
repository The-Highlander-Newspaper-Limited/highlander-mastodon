# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountCategory do
  describe 'validations' do
    subject { Fabricate.build(:account_category) }

    it { is_expected.to validate_uniqueness_of(:account_id).scoped_to(:category_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:account).inverse_of(:account_categories) }
    it { is_expected.to belong_to(:category).inverse_of(:account_categories) }
  end
end
