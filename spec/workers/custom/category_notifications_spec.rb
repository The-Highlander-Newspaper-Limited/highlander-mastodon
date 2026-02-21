# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Custom::CategoryNotifications do
  subject { FeedInsertWorker.new }

  describe 'perform' do
    let(:reader) { Fabricate(:account) }

    context 'when category notifications are configured' do
      let(:author) { Fabricate(:account) }
      let(:status) { Fabricate(:status, account: author) }
      let(:category) { Fabricate(:category) }

      before do
        Fabricate(:account_category, account: author, category: category)
        Fabricate(:account_category_notification, account: reader, category: category)

        allow(FeedManager.instance).to receive(:push_to_home)
        allow(FeedManager.instance).to receive(:filter).and_return(nil)
        allow(LocalNotificationWorker).to receive(:perform_async)
      end

      it 'sends a status notification' do
        subject.perform(status.id, reader.id)

        expect(LocalNotificationWorker).to have_received(:perform_async).with(reader.id, status.id, 'Status', 'status')
      end
    end

    context 'when category notifications are not configured' do
      let(:author) { Fabricate(:account) }
      let(:status) { Fabricate(:status, account: author) }
      let(:category) { Fabricate(:category) }

      before do
        Fabricate(:account_category, account: author, category: category)

        allow(FeedManager.instance).to receive(:push_to_home)
        allow(FeedManager.instance).to receive(:filter).and_return(nil)
        allow(LocalNotificationWorker).to receive(:perform_async)
      end

      it 'does not send a status notification' do
        subject.perform(status.id, reader.id)

        expect(LocalNotificationWorker).to_not have_received(:perform_async)
      end
    end
  end
end
