# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::CategoryNotificationSerializer do
  subject { serialized_record_json(notification, described_class) }

  let(:account) { Fabricate(:account) }
  let(:category) { Fabricate(:category, name: 'SerializeMe', mandatory_for_readers: true) }
  let(:notification) { Fabricate(:account_category_notification, account: account, category: category) }

  it 'serializes all the expected attributes' do
    expect(subject).to include(
      'id' => notification.id.to_s,
      'category' => a_hash_including(
        'id' => category.id,
        'name' => 'SerializeMe',
        'mandatory_for_readers' => true
      )
    )
  end
end
