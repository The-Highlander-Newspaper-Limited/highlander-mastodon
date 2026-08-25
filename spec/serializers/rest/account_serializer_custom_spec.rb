# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::AccountSerializer, type: :serializer do
  subject { serialized_record_json(account, described_class) }

  let(:role) { Fabricate(:user_role, permissions: UserRole::FLAGS[:create_statuses]) }
  let(:user) { Fabricate(:user, role: role) }
  let(:account) { user.account }

  context 'when local account whose role allows creating statuses' do
    it 'exposes can_create_statuses' do
      expect(subject[:can_create_statuses] || subject['can_create_statuses']).to be(true)
    end
  end

  context 'when role includes interaction flags (reply/reblog/fav)' do
    let(:role) do
      Fabricate(
        :user_role,
        permissions: UserRole::FLAGS[:reply_to_statuses] |
                     UserRole::FLAGS[:reblog_statuses] |
                     UserRole::FLAGS[:fav_statuses]
      )
    end

    it 'exposes all the interaction flags' do
      expect(subject[:can_reply_to_statuses] || subject['can_reply_to_statuses']).to be(true)
      expect(subject[:can_reblog_statuses] || subject['can_reblog_statuses']).to be(true)
      expect(subject[:can_fav_statuses] || subject['can_fav_statuses']).to be(true)
    end
  end

  context 'when account has no associated user' do
    let(:account) { Fabricate(:account, user: nil) }

    it 'returns false for can_*' do
      expect(subject[:can_create_statuses] || subject['can_create_statuses']).to be(false)
      expect(subject[:can_reply_to_statuses] || subject['can_reply_to_statuses']).to be(false)
      expect(subject[:can_reblog_statuses] || subject['can_reblog_statuses']).to be(false)
      expect(subject[:can_fav_statuses] || subject['can_fav_statuses']).to be(false)
    end
  end

  context 'when account is unavailable' do
    it 'returns false for can_*' do
      allow(account).to receive(:unavailable?).and_return(true)

      expect(subject[:can_create_statuses] || subject['can_create_statuses']).to be(false)
      expect(subject[:can_reply_to_statuses] || subject['can_reply_to_statuses']).to be(false)
      expect(subject[:can_reblog_statuses] || subject['can_reblog_statuses']).to be(false)
      expect(subject[:can_fav_statuses] || subject['can_fav_statuses']).to be(false)
    end
  end

  context 'when remote account (serializer condition: local?)' do
    let(:account) { Fabricate(:account, user: user, domain: 'example.com') }

    it 'does not include can_* attributes' do
      keys = subject.keys.map(&:to_s)

      expect(keys).to_not include('can_create_statuses')
      expect(keys).to_not include('can_reply_to_statuses')
      expect(keys).to_not include('can_reblog_statuses')
      expect(keys).to_not include('can_fav_statuses')
    end
  end
end
