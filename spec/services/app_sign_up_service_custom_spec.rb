# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppSignUpService, :skip_compatibility_role, type: :service do
  let(:service) { described_class.new }
  let!(:role)   { Fabricate(:user_role, name: 'Invitee', position: 5) }
  let!(:inviter) { Fabricate(:user, role: role) }

  let(:app) { Fabricate(:application, scopes: 'read write') }
  let(:remote_ip) { IPAddr.new('198.0.2.1') }
  let(:signup_params) do
    {
      email: "test+#{SecureRandom.hex(4)}@example.com",
      password: '123456789',
      agreement: true,
      locale: 'en',
      invite_code: invite.code,
      username: "tester_#{SecureRandom.hex(3)}",
      reason: 'Because',
      date_of_birth: '01.01.2000',
    }
  end

  describe '#call' do
    context 'with invite that has a role' do
      let(:invite) { Fabricate(:invite, user: inviter, user_role: role) }

      it 'assigns the invite role to the new user' do
        access_token = service.call(app, remote_ip, signup_params)
        user = User.find(access_token.resource_owner_id)
        expect(user.role_id).to eq(role.id)
        expect(user.role).to eq(role)
      end
    end

    context 'with invite that has no role' do
      let(:invite) { Fabricate(:invite, user: inviter, user_role: nil) }

      it 'keeps role_id nil and uses everyone role accessor' do
        access_token = service.call(app, remote_ip, signup_params)
        user = User.find(access_token.resource_owner_id)
        expect(user.role_id).to be_nil
        expect(user.role.everyone?).to be true
      end
    end
  end
end
