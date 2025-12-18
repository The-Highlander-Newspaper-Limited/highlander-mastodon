# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::Custom::AccountCategories do
  let(:account) { Fabricate(:account) }
  let(:serializer_class) do
    Class.new(ActiveModel::Serializer) do
      include REST::Custom::AccountCategories

      attributes :id
    end
  end
  let(:serializer) { serializer_class.new(account) }

  describe 'included module' do
    it 'adds categories method to serializer' do
      expect(serializer).to respond_to(:categories)
    end

    it 'serializes categories with CategorySerializer' do
      category = Fabricate(:category, name: 'Test', mandatory_for_readers: true)
      account.categories << category

      serialized = serializer.as_json
      expect(serialized[:categories]).to be_an(Array)
      expect(serialized[:categories].first).to include(
        id: category.id,
        name: 'Test',
        mandatory_for_readers: true
      )
    end
  end

  describe '#categories' do
    context 'when account is unavailable' do
      before { allow(account).to receive(:unavailable?).and_return(true) }

      it 'returns empty array' do
        expect(serializer.categories).to eq([])
      end
    end

    context 'when account is available' do
      let(:category_mandatory) { Fabricate(:category, name: 'The Category', mandatory_for_readers: true) }
      let(:category_regular) { Fabricate(:category, name: 'A Category', mandatory_for_readers: false) }

      before do
        account.categories << [category_regular, category_mandatory]
        allow(account).to receive(:unavailable?).and_return(false)
      end

      it 'returns categories ordered by mandatory_for_readers desc, name asc' do
        categories = serializer.categories
        expect(categories.map(&:name)).to eq(['The Category', 'A Category'])
      end
    end
  end

  describe REST::Custom::AccountCategories::CategorySerializer do
    let(:category) { Fabricate(:category, name: 'Test', mandatory_for_readers: true) }
    let(:category_serializer) { described_class.new(category) }
    let(:serialized) { category_serializer.serializable_hash }

    it 'serializes id' do
      expect(serialized[:id]).to eq(category.id)
    end

    it 'serializes name' do
      expect(serialized[:name]).to eq('Test')
    end

    it 'serializes mandatory_for_readers' do
      expect(serialized[:mandatory_for_readers]).to be true
    end
  end
end
