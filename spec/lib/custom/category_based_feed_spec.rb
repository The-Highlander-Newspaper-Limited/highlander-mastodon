# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Custom::CategoryBasedFeed do
  subject { FeedManager.instance }

  let(:reader) { Fabricate(:account) }
  let(:author_show) { Fabricate(:account) }
  let(:author_hide) { Fabricate(:account) }
  let(:category_show) { Fabricate(:category, name: 'Showing Category') }
  let(:category_hide) { Fabricate(:category, name: 'Hidden Category') }
  let(:status_show) { Fabricate(:status, account: author_show) }
  let(:status_hide) { Fabricate(:status, account: author_hide) }

  before do
    # Ensure users are active for feed operations if needed
    [reader, author_show, author_hide].each do |account|
      account.user.update!(current_sign_in_at: Time.current)
    end

    Fabricate(:account_category, account: author_show, category: category_show)
    Fabricate(:account_category, account: author_hide, category: category_hide)
    Fabricate(:account_category_filter, account: reader, category: category_hide)
  end

  describe '#build_crutches' do
    it 'includes reader hidden categories and maps authors to categories' do
      crutches = subject.build_crutches(reader.id, [status_show, status_hide])

      expect(crutches[:hidden_categories]).to include(category_hide.id)
      expect(crutches[:authors_categories][author_show.id]).to include(category_show.id)
      expect(crutches[:authors_categories][author_hide.id]).to include(category_hide.id)
    end
  end

  describe '#filter_from_home' do
    let(:category_overlap) { Fabricate(:category, name: 'Overlap Category') }

    it 'filters statuses when the only author category is hidden by the reader' do
      expect(subject.filter(:home, status_hide, reader)).to eq(:filter)
    end

    it 'does not filter statuses when its author category is not hidden by the reader' do
      expect(subject.filter(:home, status_show, reader)).to be_nil
    end

    it 'does not filter statuses when only one of the several author categories is hidden by the reader' do
      Fabricate(:account_category, account: author_show, category: category_hide)
      Fabricate(:account_category_filter, account: reader, category: category_overlap)

      expect(subject.filter(:home, status_show, reader)).to be_nil
    end

    # TODO: Remove when all statuses is forced to have categories
    it 'does not filter a status that has no categories' do
      fresh_account = Fabricate(:account)
      fresh_account.user.update!(current_sign_in_at: Time.current)
      fresh_status = Fabricate(:status, account: fresh_account)

      expect(subject.filter(:home, fresh_status, reader)).to be_nil
    end

    it 'considers categories from reblog and original author (filter only when all hidden)' do
      reblogger = Fabricate(:account)
      reblogger.user.update!(current_sign_in_at: Time.current)
      Fabricate(:account_category, account: reblogger, category: category_hide)

      original = Fabricate(:status, account: author_show)
      reblog = Fabricate(:status, account: reblogger, reblog: original)

      expect(subject.filter(:home, reblog, reader)).to be_nil

      Fabricate(:account_category_filter, account: reader, category: category_show)
      expect(subject.filter(:home, reblog, reader)).to eq(:filter)
    end
  end

  describe '#populate_home' do
    let(:home_key) { FeedManager.instance.key(:home, reader.id) }
    let(:public_author) { Fabricate(:account) }
    let(:unlisted_author) { Fabricate(:account) }
    let(:private_author) { Fabricate(:account) }
    let!(:reader_status) { Fabricate(:status, account: reader) }
    let!(:public_status) { Fabricate(:status, account: public_author, visibility: :public) }
    let!(:unlisted_status) { Fabricate(:status, account: unlisted_author, visibility: :unlisted) }
    let!(:private_status) { Fabricate(:status, account: private_author, visibility: :private) }

    before do
      redis.del(home_key)
    end

    it 'includes only public statuses from non-followed accounts' do
      subject.populate_home(reader)

      home_timeline_ids = redis.zrevrangebyscore(home_key, '(+inf', '(-inf', limit: [0, 30], with_scores: true).map { |id| id.first.to_i }

      expect(home_timeline_ids).to include(reader_status.id, public_status.id)
      expect(home_timeline_ids).to_not include(unlisted_status.id, private_status.id)
    end
  end

  describe '#merge_into_home' do
    let(:from_account) { Fabricate(:account) }
    let(:into_account) { Fabricate(:account) }
    let(:home_key) { FeedManager.instance.key(:home, into_account.id) }
    let!(:public_status) { Fabricate(:status, account: from_account, visibility: :public) }
    let!(:unlisted_status) { Fabricate(:status, account: from_account, visibility: :unlisted) }
    let!(:private_status) { Fabricate(:status, account: from_account, visibility: :private) }

    before do
      into_account.user.update!(current_sign_in_at: Time.current)
      redis.del(home_key)
    end

    it 'adds only public statuses from the source account' do
      subject.merge_into_home(from_account, into_account)

      home_timeline_ids = redis.zrevrangebyscore(home_key, '(+inf', '(-inf', limit: [0, 30], with_scores: true).map { |id| id.first.to_i }

      expect(home_timeline_ids).to include(public_status.id)
      expect(home_timeline_ids).to_not include(unlisted_status.id, private_status.id)
    end
  end
end
