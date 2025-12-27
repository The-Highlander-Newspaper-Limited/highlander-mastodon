# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::HomeFeedGeneration do
  let(:user) { Fabricate(:user) }

  describe '#regenerate_home_feed!' do
    it 'delegates to regenerate_feed!' do
      allow(user).to receive(:regenerate_feed!)

      user.regenerate_home_feed!

      expect(user).to have_received(:regenerate_feed!)
    end
  end

  describe '#prepare_new_user!' do
    before do
      mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

      allow(BootstrapTimelineWorker).to receive(:perform_async)
      allow(ActivityTracker).to receive(:increment)
      allow(ActivityTracker).to receive(:record)
      allow(UserMailer).to receive(:welcome).and_return(mailer)
      allow(TriggerWebhookWorker).to receive(:perform_async)
    end

    it 'regenerates the feed after base preparation' do
      allow(user).to receive(:regenerate_feed!)

      user.send(:prepare_new_user!)

      expect(user).to have_received(:regenerate_feed!)
    end
  end
end
