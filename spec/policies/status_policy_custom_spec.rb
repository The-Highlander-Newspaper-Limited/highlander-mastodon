# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusPolicy, type: :model do
  subject { described_class }

  context 'when user role has limited posting permissions' do
    let(:role_with_create) { Fabricate(:user_role, permissions: UserRole::FLAGS[:create_statuses]) }
    let(:role_without_create) { Fabricate(:user_role, permissions: UserRole::Flags::NONE) }
    let(:account_with_create) { Fabricate(:account, user: Fabricate(:user, role: role_with_create)) }
    let(:account_without_create) { Fabricate(:account, user: Fabricate(:user, role: role_without_create)) }
    let(:status) { Fabricate(:status, account: account_with_create) }

    context 'with permissions of create?' do
      permissions :create? do
        it 'permits account with create_statuses privilege' do
          expect(described_class).to permit(account_with_create, status)
        end

        it 'denies account without create_statuses privilege' do
          expect(described_class).to_not permit(account_without_create, status)
        end
      end
    end

    context 'with permissions of favourite?' do
      permissions :favourite? do
        it 'permits when role allows fav_statuses' do
          role_with_create.permissions |= UserRole::FLAGS[:fav_statuses]
          expect(described_class).to permit(account_with_create, status)
        end

        it 'denies when role does not allow fav_statuses' do
          expect(described_class).to_not permit(account_without_create, status)
        end
      end
    end

    context 'with permissions of reblog?' do
      permissions :reblog? do
        it 'permits when role allows reblog_statuses' do
          role_with_create.permissions |= UserRole::FLAGS[:reblog_statuses]
          expect(described_class).to permit(account_with_create, status)
        end

        it 'denies when role does not allow reblog_statuses' do
          expect(described_class).to_not permit(account_without_create, status)
        end
      end
    end

    context 'with permissions of reply?' do
      permissions :reply? do
        it 'permits when role allows reply_to_statuses' do
          role_with_create.permissions |= UserRole::FLAGS[:reply_to_statuses]
          expect(described_class).to permit(account_with_create, status)
        end

        it 'denies when role does not allow reply_to_statuses' do
          expect(described_class).to_not permit(account_without_create, status)
        end
      end
    end

    context 'with permissions of quote?' do
      permissions :quote? do
        it 'permits quoting when create_statuses privilege is present' do
          expect(described_class).to permit(account_with_create, status)
        end

        it 'denies quoting when create_statuses privilege is missing' do
          expect(described_class).to_not permit(account_without_create, status)
        end
      end
    end
  end
end
