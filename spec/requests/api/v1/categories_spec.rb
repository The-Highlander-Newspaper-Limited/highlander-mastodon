# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Categories' do
  let(:user)    { Fabricate(:user) }
  let(:scopes)  { 'read:accounts' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/categories' do
    subject { get '/api/v1/categories', headers: headers }

    let(:regular_category) { Fabricate(:category, name: 'News', mandatory_for_readers: false) }
    let(:mandatory_category) { Fabricate(:category, name: 'The Highlander', mandatory_for_readers: true) }

    before do
      regular_category
      mandatory_category
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:accounts'

    it 'returns all categories ordered' do
      subject

      expect(response).to have_http_status(:success)
      expect(response.content_type).to start_with('application/json')
      expect(response.parsed_body).to eq(
        Category.ordered.map do |category|
          {
            'id' => category.id,
            'name' => category.name,
            'mandatory_for_readers' => category.mandatory_for_readers,
          }
        end
      )
    end
  end
end
