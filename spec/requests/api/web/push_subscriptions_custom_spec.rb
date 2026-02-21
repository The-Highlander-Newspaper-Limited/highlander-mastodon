# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Web Push Subscriptions' do
  let(:create_payload) do
    {
      subscription: {
        endpoint: 'https://fcm.googleapis.com/fcm/send/fiuH06a27qE:APA91bHnSiGcLwdaxdyqVXNDR9w1NlztsHb6lyt5WDKOC_Z_Q8BlFxQoR8tWFSXUIDdkyw0EdvxTu63iqamSaqVSevW5LfoFwojws8XYDXv_NRRLH6vo2CdgiN4jgHv5VLt2A8ah6lUX',
        keys: {
          p256dh: 'BEm_a0bdPDhf0SOsrnB2-ategf1hHoCnpXgQsFj5JCkcoMrMt2WHoPfEYOYPzOIs9mZE8ZUaD7VA5vouy0kEkr8=',
          auth: 'eH_C8rq2raXqlcBVDa1gLg==',
        },
        standard: standard,
      },
    }
  end

  let(:alerts_payload) do
    {
      data: {
        policy: 'all',

        alerts: {
          follow: true,
          follow_request: false,
          favourite: false,
          reblog: true,
          mention: false,
          poll: true,
          status: false,
          quote: true,
        },
      },
    }
  end
  let(:standard) { '1' }

  describe 'POST /api/web/push_subscriptions' do
    before { sign_in(user) }

    let(:user) { Fabricate :user }

    context 'when the account has category notifications' do
      let(:category) { Fabricate(:category) }

      before do
        get about_path
        user.session_activations.last.update!(user_agent: 'Mozilla/5.0 (X11; Linux x86_64)')
        Fabricate(:account_category_notification, account: user.account, category: category)
      end

      it 'enables status alerts by default' do
        post api_web_push_subscriptions_path, params: create_payload

        expect(response).to have_http_status(200)
        expect(response.parsed_body.dig('alerts', 'status')).to be(true)
      end
    end
  end
end
