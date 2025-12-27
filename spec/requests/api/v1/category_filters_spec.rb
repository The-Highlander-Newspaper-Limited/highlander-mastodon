# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Category filters' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/category_filters' do
    subject { get '/api/v1/category_filters', headers: headers }

    let(:scopes)  { 'read:accounts' }
    let(:category_news) { Fabricate(:category, name: 'News') }
    let(:category_ads) { Fabricate(:category, name: 'Ads') }
    let!(:category_filter_news) { Fabricate(:account_category_filter, account: user.account, category: category_news) }
    let!(:category_filter_ads) { Fabricate(:account_category_filter, account: user.account, category: category_ads) }

    before do
      Fabricate(:account_category_filter) # Other account's filter
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:accounts'

    it 'returns the current account category filters', :aggregate_failures do
      subject

      expect(response).to have_http_status(:success)
      expect(response.content_type).to start_with('application/json')
      expect(response.parsed_body).to contain_exactly(
        a_hash_including(
          'id' => category_filter_news.id.to_s,
          'category' => a_hash_including('id' => category_news.id, 'name' => 'News')
        ),
        a_hash_including(
          'id' => category_filter_ads.id.to_s,
          'category' => a_hash_including('id' => category_ads.id, 'name' => 'Ads')
        )
      )
    end
  end

  describe 'POST /api/v1/category_filters/:id' do
    subject { post '/api/v1/category_filters', headers: headers, params: { id: category.id } }

    let(:scopes)   { 'write:accounts' }
    let(:category) { Fabricate(:category) }
    let!(:jobs_before) { RegenerationWorker.jobs.size }

    before do
      RegenerationWorker.jobs.clear
    end

    it_behaves_like 'forbidden for wrong scope', 'read read:accounts'

    it 'creates a category filter for the current account', :aggregate_failures do
      expect { subject }
        .to change { user.account.account_category_filters.count }.by(1)
        .and change { RegenerationWorker.jobs.size }.by(1)

      expect(RegenerationWorker.jobs.last['args']).to eq([user.account_id])
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include(
        'id' => user.account.account_category_filters.last.id.to_s,
        'category' => a_hash_including('id' => category.id)
      )
    end

    context 'when the category is mandatory' do
      let(:category) { Fabricate(:category, mandatory_for_readers: true) }

      it 'returns unprocessable entity with an error' do
        expect { subject }.to_not change(AccountCategoryFilter, :count)

        expect(RegenerationWorker.jobs.size).to eq(jobs_before)
        expect(response).to have_http_status(422)
        expect(response.parsed_body['error']).to eq(I18n.t('api.category_filters.errors.mandatory'))
      end
    end

    context 'when the category does not exist' do
      subject { post '/api/v1/category_filters', headers: headers, params: { id: 0 } }

      it 'returns not found with an error' do
        expect { subject }.to_not change(AccountCategoryFilter, :count)

        expect(RegenerationWorker.jobs.size).to eq(jobs_before)
        expect(response).to have_http_status(404)
        expect(response.parsed_body['error']).to eq(I18n.t('api.category_filters.errors.category_not_found'))
      end
    end
  end

  describe 'DELETE /api/v1/category_filters/:id' do
    subject { delete "/api/v1/category_filters/#{category.id}", headers: headers }

    let(:scopes)          { 'write:accounts' }
    let(:category)        { Fabricate(:category) }
    let!(:category_filter) { Fabricate(:account_category_filter, account: user.account, category: category) }
    let!(:jobs_before) { RegenerationWorker.jobs.size }

    before do
      RegenerationWorker.jobs.clear
    end

    it_behaves_like 'forbidden for wrong scope', 'read read:accounts'

    it 'removes the category filter for the current account', :aggregate_failures do
      expect { subject }
        .to change { user.account.account_category_filters.count }.by(-1)
        .and change { RegenerationWorker.jobs.size }.by(1)

      expect(RegenerationWorker.jobs.last['args']).to eq([user.account_id])
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to eq({})
    end

    context 'when the filter does not exist for the account' do
      before do
        category_filter.destroy!
      end

      it 'returns not found with an error' do
        expect { subject }.to_not change(AccountCategoryFilter, :count)

        expect(RegenerationWorker.jobs.size).to eq(jobs_before)
        expect(response).to have_http_status(404)
        expect(response.parsed_body['error']).to eq(I18n.t('api.category_filters.errors.not_found'))
      end
    end

    context 'when the category does not exist' do
      subject { delete '/api/v1/category_filters/0', headers: headers }

      it 'returns not found with an error' do
        expect { subject }.to_not change(AccountCategoryFilter, :count)

        expect(RegenerationWorker.jobs.size).to eq(jobs_before)
        expect(response).to have_http_status(404)
        expect(response.parsed_body['error']).to eq(I18n.t('api.category_filters.errors.category_not_found'))
      end
    end
  end
end
