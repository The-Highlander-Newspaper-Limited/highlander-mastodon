# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::DefaultDiscoverability do
  context 'when discoverable is nil' do
    it 'defaults to false for everyone role' do
      account = Fabricate(:account, discoverable: nil, indexable: false)

      expect(account.discoverable).to be false
      expect(account.indexable).to be false
    end

    it 'defaults to true for non-everyone roles' do
      role = Fabricate(:user_role)
      user = Fabricate(:user, role:)
      account = Fabricate(:account, user:, discoverable: nil, indexable: false)

      expect(account.discoverable).to be true
      expect(account.indexable).to be true
    end
  end

  context 'when discoverable is already set' do
    it 'does not override the provided value' do
      account = Fabricate(:account, discoverable: true, indexable: true)

      expect(account.discoverable).to be true
      expect(account.indexable).to be true
    end
  end
end
