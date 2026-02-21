# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::Associations do
  subject { Fabricate.build(:account) }

  describe 'associations' do
    # Categories assigned to account
    it { is_expected.to have_many(:account_categories).inverse_of(:account).dependent(:destroy) }
    it { is_expected.to have_many(:categories).through(:account_categories) }

    # Categories the account chose to filter out
    it { is_expected.to have_many(:account_category_filters).inverse_of(:account).dependent(:destroy) }

    # Categories the account wants notifications for
    it { is_expected.to have_many(:account_category_notifications).inverse_of(:account).dependent(:destroy) }
  end
end
