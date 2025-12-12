# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Accounts' do
  let(:admin) { Fabricate(:admin_user) }
  let(:account) { Fabricate(:account, username: 'test_subject') }

  before { sign_in admin }

  describe 'GET /admin/accounts/:id/categories' do
    before do
      Fabricate(:category, name: 'Highlander')

      get admin_account_categories_path(account.id)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'includes the account in the response' do
      expect(response.body).to include('test_subject')
    end

    it 'includes available categories in the response' do
      expect(response.body).to include('Highlander')
    end
  end

  describe 'PATCH /admin/accounts/:id/categories' do
    let(:category_news) { Fabricate(:category, name: 'News') }
    let(:category_sports) { Fabricate(:category, name: 'Sports') }
    let(:params) do
      {
        account: {
          category_ids: [category_news.id, category_sports.id],
        },
      }
    end

    it 'assigns categories to the account' do
      patch admin_account_categories_path(account.id), params: params

      expect(account.reload.categories).to contain_exactly(category_news, category_sports)
    end

    it 'redirects to account page' do
      patch admin_account_categories_path(account.id), params: params

      expect(response).to redirect_to(admin_account_path(account.id))
    end

    it 'displays success notice' do
      patch admin_account_categories_path(account.id), params: params

      expect(response).to have_http_status(302)
    end

    it 'logs the change_categories action' do
      expect { patch admin_account_categories_path(account.id), params: params }
        .to change(Admin::ActionLog, :count).by(1)

      log = Admin::ActionLog.last
      expect(log.action).to eq(:change_categories)
      expect(log.target).to eq(account)
    end

    context 'when removing all categories' do
      before { account.categories << [category_news, category_sports] }

      it 'removes all categories when empty array provided' do
        patch admin_account_categories_path(account.id), params: { account: { category_ids: [] } }

        expect(account.reload.categories).to be_empty
      end
    end

    context 'when validation fails (poster without categories)' do
      let(:poster_role) { Fabricate(:user_role, name: 'Poster') }

      before do
        account.user.update!(role: poster_role)
        account.categories.clear
      end

      it 'returns unprocessable_entity and re-renders the form' do
        patch admin_account_categories_path(account.id), params: { account: { category_ids: [] } }

        expect(response).to have_http_status(422)
        expect(response.body).to include(I18n.t('admin.accounts.categories.edit.page_title', username: account.username))
      end
    end
  end
end
