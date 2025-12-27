# frozen_string_literal: true

require 'rails_helper'
require 'debug'

RSpec.describe REST::CategoryFilterSerializer do
  subject { serialized_record_json(filter, described_class) }

  let(:account) { Fabricate(:account) }
  let(:category) { Fabricate(:category, name: 'SerializeMe') }
  let(:filter) { Fabricate(:account_category_filter, account: account, category: category) }

  it 'serializes all the expected attributes' do
    expect(subject).to include(
      'id' => filter.id.to_s,
      'created_at' => filter.created_at.iso8601(3),
      'category' => a_hash_including('id' => category.id, 'name' => 'SerializeMe')
    )
  end
end
