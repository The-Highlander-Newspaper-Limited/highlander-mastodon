# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings privacy permissions page' do
  let(:role) { Fabricate(:user_role, permissions: UserRole::Flags::NONE) }
  let(:user) { Fabricate(:user, role: role) }

  before { sign_in user }

  it 'hides posting-related privacy settings for users without posting permissions' do
    visit settings_privacy_path

    expect(page)
      .to have_title(I18n.t('privacy.title'))
    expect(page)
      .to have_field(I18n.t('simple_form.labels.account.unlocked'))
    expect(page)
      .to have_field(I18n.t('simple_form.labels.settings.indexable'))
    expect(page)
      .to have_no_field(I18n.t('simple_form.labels.account.discoverable'))
    expect(page)
      .to have_no_field(I18n.t('simple_form.labels.account.indexable'))
    expect(page)
      .to have_no_field(I18n.t('simple_form.labels.settings.show_application'))
  end
end
