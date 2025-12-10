# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category do
  describe 'Database columns' do
    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:description).of_type(:text) }
    it { is_expected.to have_db_column(:mandatory_for_readers).of_type(:boolean).with_options(null: false, default: false) }
  end

  describe 'Indexes' do
    it { is_expected.to have_db_index(:name).unique }
  end

  describe 'Defaults' do
    it 'sets mandatory_for_readers to false by default' do
      category = described_class.new(name: 'Test')
      expect(category.mandatory_for_readers).to be false
    end
  end

  describe 'Associations' do
    it { is_expected.to have_many(:account_categories).inverse_of(:category).dependent(:destroy) }
    it { is_expected.to have_many(:accounts).through(:account_categories) }
  end

  describe 'Validations' do
    subject { Fabricate.build(:category) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe 'Scopes' do
    describe '.ordered' do
      before { described_class.destroy_all }

      it 'returns categories ordered by mandatory_for_readers desc, then name asc' do
        mandatory_alpha = Fabricate(:category, name: 'Alpha', mandatory_for_readers: true)
        mandatory_beta = Fabricate(:category, name: 'Beta', mandatory_for_readers: true)
        optional_gamma = Fabricate(:category, name: 'Gamma', mandatory_for_readers: false)
        optional_delta = Fabricate(:category, name: 'Delta', mandatory_for_readers: false)

        expect(described_class.ordered).to eq([mandatory_alpha,
                                               mandatory_beta,
                                               optional_delta,
                                               optional_gamma])
      end
    end
  end
end
