# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountPolicy do
  subject { described_class }

  let(:admin)   { Fabricate(:admin_user).account }
  let(:john)    { Fabricate(:account) }
  let(:alice)   { Fabricate(:account) }

  permissions :change_categories? do
    context 'when user can manage categories' do
      it { is_expected.to permit(admin, alice) }
    end

    context 'when user cannot manage categories' do
      it { is_expected.to_not permit(john, alice) }
    end
  end
end
