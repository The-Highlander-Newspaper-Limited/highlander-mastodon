# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings preferences other page' do
  let(:user) { Fabricate :user }

  before { sign_in user }

  it 'Views and updates user prefs' do
    visit settings_preferences_other_path

    expect(page)
      .to have_private_cache_control

    uncheck aggregate_reblogs_field

    expect { save_changes }
      .to change { user.reload.settings['aggregate_reblogs'] }.to(false)
    expect(page)
      .to have_title(I18n.t('settings.preferences'))
  end

  def save_changes
    within('form') { click_on submit_button }
  end

  def aggregate_reblogs_field
    form_label('defaults.setting_aggregate_reblogs')
  end
end
