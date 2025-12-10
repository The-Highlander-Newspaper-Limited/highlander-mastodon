# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Status do
  subject { Fabricate(:status, account: alice) }

  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:bob)   { Fabricate(:account, username: 'bob') }
  let(:other) { Fabricate(:status, account: bob, text: 'Skulls for the skull god! The enemy\'s gates are sideways!') }

  describe 'Delegations' do
    describe 'categories' do
      let(:category) { Fabricate(:category, name: 'News') }

      it 'delegates to account' do
        alice.categories << category

        expect(subject.categories).to contain_exactly(category)
      end

      it 'returns empty when account has no categories' do
        expect(subject.categories).to be_empty
      end

      it 'returns nil when account is nil' do
        subject.account = nil

        expect(subject.categories).to be_nil
      end
    end
  end
end
