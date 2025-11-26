# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invite, :skip_compatibility_role do
  describe 'Associations' do
    it { is_expected.to belong_to(:user_role).optional }
  end

  describe '#validate_role_assignment' do
    let!(:low_role)  { Fabricate(:user_role, name: 'Lowrole', position: 5) }
    let!(:mid_role)  { Fabricate(:user_role, name: 'Midrole', position: 10) }
    let!(:high_role) { Fabricate(:user_role, name: 'Highrole', position: 20) }
    let(:inviting_user) { Fabricate(:user, role: mid_role) }

    context 'when assigning a higher role than inviter has' do
      it 'is invalid and adds elevated error' do
        invite = Fabricate.build(:invite, user: inviting_user, user_role: high_role)
        expect(invite).to_not be_valid
        expect(invite.errors.of_kind?(:user_role_id, :elevated)).to be true
      end
    end

    context 'when assigning an equal role' do
      it 'is valid' do
        invite = Fabricate.build(:invite, user: inviting_user, user_role: mid_role)
        expect(invite).to be_valid
      end
    end

    context 'when assigning a lower role' do
      it 'is valid' do
        invite = Fabricate.build(:invite, user: inviting_user, user_role: low_role)
        expect(invite).to be_valid
      end
    end

    context 'when no role is assigned' do
      it 'is valid' do
        invite = Fabricate.build(:invite, user: inviting_user, user_role: nil)
        expect(invite).to be_valid
      end
    end
  end
end
