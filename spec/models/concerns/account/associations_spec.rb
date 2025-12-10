# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::Associations do
  subject { Fabricate.build(:account) }

  describe 'associations' do
    it { is_expected.to have_many(:account_categories).inverse_of(:account).dependent(:destroy) }
    it { is_expected.to have_many(:categories).through(:account_categories) }
  end
end
