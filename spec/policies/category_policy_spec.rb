# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CategoryPolicy do
  subject { described_class }

  let(:admin) { Fabricate(:admin_user).account }
  let(:account) { Fabricate(:account) }

  permissions :index?, :create? do
    context 'when admin' do
      it { is_expected.to permit(admin, Category.new) }
    end

    context 'when not admin' do
      it { is_expected.to_not permit(account, Category.new) }
    end
  end

  permissions :update? do
    context 'when admin' do
      it { is_expected.to permit(admin, Category.new) }
    end

    context 'when not admin' do
      it { is_expected.to_not permit(account, Category.new) }
    end
  end

  permissions :destroy? do
    context 'when admin' do
      it { is_expected.to permit(admin, Category.new) }
    end

    context 'when not admin' do
      it { is_expected.to_not permit(account, Category.new) }
    end
  end
end
