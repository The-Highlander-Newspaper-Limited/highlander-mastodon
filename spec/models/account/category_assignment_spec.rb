# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::CategoryAssignment do
  let(:poster_role) { Fabricate(:user_role, name: 'Poster') }
  let(:poster_user) { Fabricate(:user, role: poster_role) }
  let(:non_poster_user) { Fabricate(:user) }
  let(:poster_account) { poster_user.account }
  let(:non_poster_account) { non_poster_user.account }

  describe 'Validations' do
    describe '#poster_must_have_category' do
      it 'allows creation without categories (validation runs only on update)' do
        new_account = Fabricate.build(:account, user: poster_user, categories: [])

        expect(new_account).to be_valid
      end

      it 'adds error on update when categories are empty' do
        poster_account.categories.clear

        expect(poster_account.valid?(:update)).to be false
        expect(poster_account.errors[:categories]).to include(I18n.t('activerecord.errors.models.account.attributes.categories.poster_role'))
      end

      it 'passes update when a category is present' do
        category = Fabricate(:category, name: 'Some Category')
        poster_account.categories << category

        expect(poster_account.valid?(:update)).to be true
      end

      it 'allows non-poster user to have no categories' do
        non_poster_account.categories.clear

        expect(non_poster_account.valid?(:update)).to be true
      end
    end
  end
end
