# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserRole do
  describe 'Constants' do
    describe 'Flags::INTERACTION' do
      it 'is the combination of reply, favorite and reblog flags' do
        expected = UserRole::FLAGS[:reply_to_statuses] | UserRole::FLAGS[:fav_statuses] | UserRole::FLAGS[:reblog_statuses]

        expect(UserRole::Flags::INTERACTION).to eq(expected)
      end
    end
  end

  describe '#can?' do
    subject { Fabricate :user_role }

    context 'with custom posting-interaction permissions' do
      it 'supports create, reply, fav, and reblog flags' do
        role = Fabricate(:user_role,
                         permissions: UserRole::FLAGS[:create_statuses] |
                                      UserRole::FLAGS[:reply_to_statuses] |
                                      UserRole::FLAGS[:fav_statuses] |
                                      UserRole::FLAGS[:reblog_statuses])

        expect(role.can?(:create_statuses)).to be true
        expect(role.can?(:reply_to_statuses)).to be true
        expect(role.can?(:fav_statuses)).to be true
        expect(role.can?(:reblog_statuses)).to be true
      end

      it 'categorizes them under interaction' do
        expect(UserRole::Flags::CATEGORIES[:interaction])
          .to include(:reply_to_statuses, :fav_statuses, :reblog_statuses)
      end
    end
  end

  describe '#validate_dangerous_permissions' do
    let(:everyone) { described_class.everyone }

    it 'allows DEFAULT + INTERACTION for the everyone role' do
      everyone.permissions = UserRole::Flags::DEFAULT | UserRole::Flags::INTERACTION

      expect(everyone).to be_valid
    end

    it 'is invalid when everyone has additional dangerous flags' do
      everyone.permissions = UserRole::Flags::DEFAULT | UserRole::Flags::INTERACTION | UserRole::FLAGS[:administrator]

      expect(everyone.valid?).to be(false)
      expect(everyone.errors[:permissions_as_keys]).to_not be_empty
    end
  end
end
