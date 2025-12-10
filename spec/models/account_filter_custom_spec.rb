# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountFilter do
  describe 'filtering by categories' do
    let(:category_news) { Fabricate(:category, name: 'News') }
    let(:category_sports) { Fabricate(:category, name: 'Sports') }
    let(:account_news) { Fabricate(:account) }
    let(:account_sports) { Fabricate(:account) }
    let(:account_all_in) { Fabricate(:account) }

    before do
      account_news.categories << category_news
      account_sports.categories << category_sports
      account_all_in.categories << [category_news, category_sports]
    end

    it 'filters accounts by single category' do
      filter = described_class.new(category_ids: [category_news.id])
      results = filter.results

      expect(results).to include(account_news, account_all_in)
      expect(results).to_not include(account_sports)
    end

    it 'filters accounts by multiple categories' do
      filter = described_class.new(category_ids: [category_news.id, category_sports.id])
      results = filter.results

      expect(results).to include(account_news, account_sports, account_all_in)
    end

    it 'returns distinct results when account has multiple matching categories' do
      filter = described_class.new(category_ids: [category_news.id, category_sports.id])
      results = filter.results.to_a

      expect(results.count(account_all_in)).to eq(1)
    end

    it 'returns empty when filtering by non-existent category' do
      filter = described_class.new(category_ids: [999_999])
      results = filter.results

      expect(results).to be_empty
    end
  end

  describe 'KEYS constant' do
    it 'includes category_ids' do
      expect(described_class::KEYS).to include(:category_ids)
    end
  end
end
