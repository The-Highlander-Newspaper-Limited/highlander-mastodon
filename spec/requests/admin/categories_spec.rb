# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Categories' do
  let(:admin) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before { sign_in admin }

  describe 'GET /admin/categories' do
    before do
      Fabricate(:category, mandatory_for_readers: true, name: 'Highlander News')
      Fabricate(:category, mandatory_for_readers: false, name: 'Automotive')
      Fabricate(:category, mandatory_for_readers: false, name: 'Books')

      get admin_categories_path
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'includes the category in the response' do
      expect(response.body).to include('Automotive')
    end

    it 'orders categories by mandatory first, then name' do
      mandatory_index = response.body.index('Highlander News')
      first_optional_index = response.body.index('Automotive')
      second_optional_index = response.body.index('Books')

      expect(mandatory_index).to be < first_optional_index
      expect(first_optional_index).to be < second_optional_index
    end
  end

  describe 'GET /admin/categories/new' do
    before { get new_admin_category_path }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'includes form in response' do
      expect(response.body).to include('form')
    end
  end

  describe 'GET /admin/categories/:id/edit' do
    let(:category) { Fabricate(:category, name: 'Highlander') }

    before { get edit_admin_category_path(category) }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'includes category name in response' do
      expect(response.body).to include('Highlander')
    end
  end

  describe 'POST /admin/categories' do
    context 'with valid params' do
      let(:valid_params) do
        {
          category: {
            name: 'Test Category',
            description: 'A test category',
            mandatory_for_readers: false,
          },
        }
      end

      it 'creates a new category' do
        expect { post admin_categories_path, params: valid_params }.to change(Category, :count).by(1)
      end

      it 'redirects to categories index' do
        post admin_categories_path, params: valid_params

        expect(response).to redirect_to(admin_categories_path)
      end

      it 'logs the create action' do
        expect { post admin_categories_path, params: valid_params }
          .to change(Admin::ActionLog, :count).by(1)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          category: {
            name: '',
            description: 'Invalid',
          },
        }
      end

      it 'does not create a category' do
        expect { post admin_categories_path, params: invalid_params }.to_not change(Category, :count)
      end

      it 'returns http unprocessable_entity' do
        post admin_categories_path, params: invalid_params

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PATCH /admin/categories/:id' do
    let(:category) { Fabricate(:category) }

    context 'with valid params' do
      let(:valid_params) do
        {
          category: {
            name: 'Updated Name',
            mandatory_for_readers: true,
          },
        }
      end

      it 'updates the category' do
        patch admin_category_path(category), params: valid_params

        category.reload
        expect(category.name).to eq('Updated Name')
        expect(category.mandatory_for_readers).to be true
      end

      it 'redirects to categories index' do
        patch admin_category_path(category), params: valid_params

        expect(response).to redirect_to(admin_categories_path)
      end

      it 'logs the update action' do
        expect { patch admin_category_path(category), params: valid_params }
          .to change(Admin::ActionLog, :count).by(1)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          category: {
            name: '',
          },
        }
      end

      it 'does not update the category' do
        original_name = category.name

        patch admin_category_path(category), params: invalid_params

        expect(category.reload.name).to eq(original_name)
      end

      it 'returns http unprocessable_entity' do
        patch admin_category_path(category), params: invalid_params

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE /admin/categories/:id' do
    let!(:category) { Fabricate(:category) }

    it 'destroys the category' do
      expect { delete admin_category_path(category) }.to change(Category, :count).by(-1)
    end

    it 'redirects to categories index' do
      delete admin_category_path(category)

      expect(response).to redirect_to(admin_categories_path)
    end

    it 'logs the destroy action' do
      expect { delete admin_category_path(category) }.to change(Admin::ActionLog, :count).by(1)
    end
  end
end
