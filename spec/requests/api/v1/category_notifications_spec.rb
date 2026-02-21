# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Category notifications' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/category_notifications' do
    subject { get '/api/v1/category_notifications', headers: headers }

    let(:scopes)  { 'read:accounts' }
    let(:category_news) { Fabricate(:category, name: 'News') }
    let(:category_ads) { Fabricate(:category, name: 'Ads') }
    let!(:category_notification_news) { Fabricate(:account_category_notification, account: user.account, category: category_news) }
    let!(:category_notification_ads) { Fabricate(:account_category_notification, account: user.account, category: category_ads) }

    before do
      Fabricate(:account_category_notification) # Other account's notification
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:accounts'

    it 'returns the current account category notifications', :aggregate_failures do
      subject

      expect(response).to have_http_status(:success)
      expect(response.content_type).to start_with('application/json')
      expect(response.parsed_body).to contain_exactly(
        a_hash_including(
          'id' => category_notification_news.id.to_s,
          'category' => a_hash_including('id' => category_news.id, 'name' => 'News')
        ),
        a_hash_including(
          'id' => category_notification_ads.id.to_s,
          'category' => a_hash_including('id' => category_ads.id, 'name' => 'Ads')
        )
      )
    end
  end

  describe 'POST /api/v1/category_notifications/:id' do
    subject { post '/api/v1/category_notifications', headers: headers, params: { id: category.id } }

    let(:scopes)   { 'write:accounts' }
    let(:category) { Fabricate(:category) }

    it_behaves_like 'forbidden for wrong scope', 'read read:accounts'

    it 'creates a category notification for the current account', :aggregate_failures do
      expect { subject }
        .to change { user.account.account_category_notifications.count }.by(1)

      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include(
        'id' => user.account.account_category_notifications.last.id.to_s,
        'category' => a_hash_including('id' => category.id)
      )
    end

    context 'when the category does not exist' do
      subject { post '/api/v1/category_notifications', headers: headers, params: { id: 0 } }

      it 'returns not found with an error' do
        expect { subject }.to_not change(AccountCategoryNotification, :count)

        expect(response).to have_http_status(404)
        expect(response.parsed_body['error']).to eq(I18n.t('api.category_notifications.errors.category_not_found'))
      end
    end
  end

  describe 'DELETE /api/v1/category_notifications/:id' do
    subject { delete "/api/v1/category_notifications/#{category.id}", headers: headers }

    let(:scopes)          { 'write:accounts' }
    let(:category)        { Fabricate(:category) }
    let!(:category_notification) { Fabricate(:account_category_notification, account: user.account, category: category) }

    it_behaves_like 'forbidden for wrong scope', 'read read:accounts'

    it 'removes the category notification for the current account', :aggregate_failures do
      expect { subject }
        .to change { user.account.account_category_notifications.count }.by(-1)

      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to eq({})
    end

    context 'when the notification does not exist for the account' do
      before do
        category_notification.destroy!
      end

      it 'returns not found with an error' do
        expect { subject }.to_not change(AccountCategoryNotification, :count)

        expect(response).to have_http_status(404)
        expect(response.parsed_body['error']).to eq(I18n.t('api.category_notifications.errors.not_found'))
      end
    end

    context 'when the category does not exist' do
      subject { delete '/api/v1/category_notifications/0', headers: headers }

      it 'returns not found with an error' do
        expect { subject }.to_not change(AccountCategoryNotification, :count)

        expect(response).to have_http_status(404)
        expect(response.parsed_body['error']).to eq(I18n.t('api.category_notifications.errors.category_not_found'))
      end
    end
  end
end
