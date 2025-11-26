# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserRole, :skip_compatibility_role do
  describe 'Constants' do
    describe 'Flags::INTERACTION' do
      it 'is the combination of reply, favorite and reblog flags' do
        expected = UserRole::FLAGS[:reply_to_statuses] | UserRole::FLAGS[:fav_statuses] | UserRole::FLAGS[:reblog_statuses]

        expect(UserRole::Flags::INTERACTION).to eq(expected)
      end
    end
  end

  describe 'Scopes' do
    before { described_class.delete_all }

    describe '.assignable' do
      let!(:regular_role) { Fabricate(:user_role, name: 'Regular', position: 10) }
      let!(:another_role) { Fabricate(:user_role, name: 'Another', position: 20) }

      it 'excludes the everyone role' do
        expect(described_class.assignable).to_not include(described_class.everyone)
      end

      it 'includes regular roles, ordered ascending by position' do
        expect(described_class.assignable).to eq([regular_role, another_role])
      end
    end

    describe '.assignable_by' do
      let!(:low_role)    { Fabricate(:user_role, name: 'Low', position: 10) }
      let!(:mid_role)    { Fabricate(:user_role, name: 'Mid', position: 20) }
      let!(:high_role)   { Fabricate(:user_role, name: 'High', position: 30) }
      let!(:higher_role) { Fabricate(:user_role, name: 'Higher', position: 40) }

      context 'when user has mid-level role' do
        let(:user) { Fabricate(:user, role: mid_role) }

        it 'returns roles with position less than or equal to user role position' do
          result = described_class.assignable_by(user)
          expect(result).to eq([low_role, mid_role]) # ordered ascending by position
        end

        it 'excludes everyone role' do
          result = described_class.assignable_by(user)
          expect(result).to_not include(described_class.everyone)
        end
      end

      context 'when user has highest role' do
        let(:user) { Fabricate(:user, role: higher_role) }

        it 'returns all assignable roles (ordered ascending by position)' do
          result = described_class.assignable_by(user)
          expect(result).to eq([low_role, mid_role, high_role, higher_role])
        end
      end

      context 'when user has lowest role' do
        let(:user) { Fabricate(:user, role: low_role) }

        it 'returns only the same role' do
          result = described_class.assignable_by(user)
          expect(result).to contain_exactly(low_role)
        end
      end

      context 'when user has no role (everyone role)' do
        let(:user) { Fabricate(:user, role: nil) }

        it 'returns no assignable roles' do
          result = described_class.assignable_by(user)
          expect(result).to be_empty
        end
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
