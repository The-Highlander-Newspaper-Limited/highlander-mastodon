# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Invites', :skip_compatibility_role do
  let(:admin_user) { Fabricate(:admin_user) }
  let!(:low_role)  do
    Fabricate(:user_role, name: 'Lowrole', position: 10, permissions: UserRole::FLAGS[:manage_invites])
  end
  let!(:high_role) do
    Fabricate(:user_role, name: 'Highrole', position: 20, permissions: UserRole::FLAGS[:manage_invites])
  end

  describe 'GET /admin/invites' do
    context 'when signed in as admin' do
      before { sign_in admin_user }

      it 'displays invites page successfully' do
        Fabricate(:invite, user: admin_user, user_role: low_role)

        get admin_invites_path

        expect(response).to have_http_status(200)
        expect(response.body).to include('Lowrole') # Role name displayed
      end

      it 'displays role selector with all roles for admin' do
        get admin_invites_path

        expect(response).to have_http_status(200)
        expect(response.body).to include('Lowrole')
        expect(response.body).to include('Highrole')
      end
    end

    context 'when signed in as user with lower role' do
      let(:low_role_user) { Fabricate(:user, role: low_role) }

      before { sign_in low_role_user }

      it 'displays role selector with only assignable roles' do
        get admin_invites_path

        expect(response).to have_http_status(200)
        expect(response.body).to include('Lowrole')
        expect(response.body).to_not include('Highrole')
      end
    end
  end

  describe 'POST /admin/invites' do
    let(:low_role_user) { Fabricate(:user, role: low_role) }

    before { sign_in admin_user }

    it 'accepts user_role_id parameter and creates invite with role' do
      post admin_invites_path(invite: { max_uses: 10, expires_in: 86_400, user_role_id: low_role.id })

      expect(response).to redirect_to(admin_invites_path)
      expect(Invite.last.user_role_id).to eq(low_role.id)
    end

    it 'rejects creation when trying to assign elevated role' do
      sign_in low_role_user

      post admin_invites_path(invite: { max_uses: 10, expires_in: 86_400, user_role_id: high_role.id })

      expect(response).to have_http_status(200) # Renders index with errors
      expect(Invite.last).to be_nil # Invite not created
    end
  end
end
