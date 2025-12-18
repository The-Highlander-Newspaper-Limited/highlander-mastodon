# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CategoriesHelper do
  describe '#category_badge' do
    let(:category) { Fabricate(:category, name: 'Test Category') }

    context 'when category is mandatory for readers' do
      before { category.update(mandatory_for_readers: true) }

      it 'returns a span with mandatory variant class' do
        result = helper.category_badge(category)
        expect(result).to have_css('span.category-badge.category-badge--mandatory', text: 'Test Category')
      end
    end

    context 'when category is not mandatory' do
      before { category.update(mandatory_for_readers: false) }

      it 'returns a span with regular variant class' do
        result = helper.category_badge(category)
        expect(result).to have_css('span.category-badge.category-badge--regular', text: 'Test Category')
      end
    end
  end
end
