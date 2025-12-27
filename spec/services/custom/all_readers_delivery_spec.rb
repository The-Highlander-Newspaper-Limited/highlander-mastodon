# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Custom::AllReadersDelivery, :skip_compatibility_role do
  subject { FanOutOnWriteService.new }

  let(:status_acccount) { Fabricate(:account) }
  let(:status) { Fabricate(:status, account: status_acccount) }
  let(:accounts) { [Fabricate(:account), Fabricate(:account), status_acccount] }

  it 'pushes feed inserts for active accounts in batches (integration-style)' do
    # Make users appear recently active so User.signed_in_recently matches them
    accounts.each { |a| a.user.update!(current_sign_in_at: Time.current) }

    # Spy on push_bulk and capture the payloads produced by the provided block
    captured_rows = nil
    allow(FeedInsertWorker).to receive(:push_bulk) do |batch, &blk|
      captured_rows = batch.map { |acc| blk.call(acc) }
    end

    subject.call(status)

    expect(captured_rows.size).to eq(accounts.size)
    expect(captured_rows.pluck(1)).to eq(accounts.pluck(:id))
    captured_rows.each do |row|
      expect(row[0]).to eq(status.id)
      expect(row[2]).to include('home')
      expect(row[3]).to eq({ 'update' => nil })
    end
  end

  it 'does not fan-out when the status is not public' do
    non_public_status = Fabricate(:status, account: status_acccount, visibility: :unlisted)

    allow(FeedInsertWorker).to receive(:push_bulk)

    subject.call(non_public_status)

    expect(FeedInsertWorker).to_not have_received(:push_bulk)
  end
end
