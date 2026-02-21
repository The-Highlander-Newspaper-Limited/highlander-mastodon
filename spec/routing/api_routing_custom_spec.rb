# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API routes' do
  describe 'Category filters routes' do
    it 'routes index' do
      expect(get('/api/v1/category_filters'))
        .to route_to('api/v1/category_filters#index')
    end

    it 'routes create' do
      expect(post('/api/v1/category_filters'))
        .to route_to('api/v1/category_filters#create')
    end

    it 'routes destroy' do
      expect(delete('/api/v1/category_filters/123'))
        .to route_to('api/v1/category_filters#destroy', id: '123')
    end
  end

  describe 'Category notifications routes' do
    it 'routes index' do
      expect(get('/api/v1/category_notifications'))
        .to route_to('api/v1/category_notifications#index')
    end

    it 'routes create' do
      expect(post('/api/v1/category_notifications'))
        .to route_to('api/v1/category_notifications#create')
    end

    it 'routes destroy' do
      expect(delete('/api/v1/category_notifications/123'))
        .to route_to('api/v1/category_notifications#destroy', id: '123')
    end
  end
end
