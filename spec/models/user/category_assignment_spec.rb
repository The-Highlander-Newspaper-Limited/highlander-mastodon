# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::CategoryAssignment do
  let(:user) { Fabricate(:user, role: role) }
  let(:poster_role) { Fabricate(:user_role, name: 'Poster') }
  let(:other_role)  { Fabricate(:user_role, name: 'Reporter') }
  let(:new_poster_category) { Category.find_or_create_by!(name: 'New Poster') }

  describe '#poster?' do
    context 'with Poster role' do
      let(:role) { poster_role }

      it 'returns true' do
        expect(user.poster?).to be true
      end
    end

    context 'with non-Poster role' do
      let(:role) { other_role }

      it 'returns false' do
        expect(user.poster?).to be false
      end
    end

    context 'with no role' do
      let(:role) { nil }

      it 'returns false' do
        expect(user.poster?).to be false
      end
    end
  end

  describe 'Callbacks' do
    describe '#assign_new_poster_category' do
      let(:role) { poster_role }

      context 'when after_create' do
        it 'assigns New Poster category when user is created with Poster role' do
          expect(user.account.categories).to include(new_poster_category)
        end
      end

      context 'when after_update' do
        let(:role) { other_role }

        it 'assigns New Poster category when role changes to Poster' do
          user.account.categories.clear

          user.update!(role: poster_role)

          expect(user.account.categories).to include(new_poster_category)
        end

        it 'does not duplicate category if already assigned' do
          user.account.categories << new_poster_category

          expect { user.update!(role: poster_role) }
            .to_not(change { user.account.categories.where(id: new_poster_category.id).count })
        end
      end

      context 'when guard clauses' do
        let(:role) { other_role }
        let(:no_account_user) { Fabricate.build(:user, role: poster_role, account: nil) }

        it 'returns early when account is blank' do
          expect { no_account_user.send(:assign_new_poster_category) }.to_not raise_error
        end

        it 'returns early when category does not exist' do
          new_poster_category.destroy
          user.account.categories.clear

          user.send(:assign_new_poster_category)

          expect(user.account.categories).to be_empty
        end

        it 'returns early when category already assigned' do
          user.account.categories << new_poster_category

          expect { user.send(:assign_new_poster_category) }
            .to_not(change { user.account.categories.count })
        end
      end
    end
  end
end
