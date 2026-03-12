# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings preferences posting defaults permissions page' do
  let(:role) { Fabricate(:user_role, permissions: UserRole::Flags::NONE) }
  let(:user) { Fabricate(:user, role: role) }

  before { sign_in user }

  it 'hides the posting defaults link for users without posting permissions' do
    visit settings_preferences_appearance_path

    expect(page)
      .to have_title(I18n.t('settings.appearance'))
    expect(page)
      .to have_no_link(I18n.t('preferences.posting_defaults'), href: settings_preferences_posting_defaults_path)
    expect(page)
      .to have_no_link(I18n.t('settings.statuses_cleanup'), href: statuses_cleanup_path)
  end
end
