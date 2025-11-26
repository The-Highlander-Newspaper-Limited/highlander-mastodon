# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::RegistrationsController, :skip_compatibility_role do
  render_views

  describe 'POST #create' do
    subject { post :create, params: }

    let(:inviter) { Fabricate(:user, confirmed_at: 2.days.ago, role: user_role) }
    let(:invite) { Fabricate(:invite, user: inviter, max_uses: nil, expires_at: 1.hour.from_now, user_role:) }
    let(:params) do
      {
        user: {
          account_attributes: { username: 'test' },
          email: 'test@example.com',
          password: '12345678',
          password_confirmation: '12345678',
          invite_code: invite.code,
          agreement: 'true',
        },
      }
    end

    before do
      session[:registration_form_time] = 5.seconds.ago

      request.env['devise.mapping'] = Devise.mappings[:user]

      Setting.registrations_mode = 'open'
    end

    context 'with invite that has an assigned role' do
      let(:user_role) { Fabricate(:user_role, name: 'Invitee', position: 10) }

      it 'creates user with the role from invite' do
        subject

        expect(response).to redirect_to auth_setup_path

        user = User.find_by(email: 'test@example.com')
        expect(user).to be_present
        expect(user.role.name).to eq('Invitee')
      end
    end

    context 'with invite that has no assigned role' do
      let(:user_role) { nil }

      it 'creates user with default everyone role' do
        subject

        expect(response).to redirect_to auth_setup_path

        user = User.find_by(email: 'test@example.com')
        expect(user).to be_present
        expect(user.role_id).to be_nil
        expect(user.role.everyone?).to be true
      end
    end
  end
end
