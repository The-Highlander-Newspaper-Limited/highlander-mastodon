# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountCategoryFilter do
  describe 'Associations' do
    it { is_expected.to belong_to(:account).inverse_of(:account_category_filters) }
    it { is_expected.to belong_to(:category).inverse_of(:account_category_filters) }
  end

  describe 'Validations' do
    subject { Fabricate.build(:account_category_filter) }

    let(:mandatory_category) { Fabricate(:category, mandatory_for_readers: true) }

    it { is_expected.to validate_uniqueness_of(:category_id).scoped_to(:account_id) }

    it 'rejects filtering a mandatory category' do
      subject.category = mandatory_category

      expect(subject).to_not be_valid
      expect(subject.errors[:category]).to be_present
      expect(subject.errors[:category]).to include(I18n.t('activerecord.errors.models.account_category_filter.attributes.category.mandatory'))
    end
  end
end
