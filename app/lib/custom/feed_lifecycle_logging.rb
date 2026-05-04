# frozen_string_literal: true

module Custom::FeedLifecycleLogging
  def self.log_event(event, attributes = {})
    Rails.logger.info do
      attributes
        .compact
        .reduce(["event=#{event}"]) { |parts, (key, value)| parts << "#{key}=#{value}" }
        .join(' ')
    end
  end

  def self.feed_clean_caller
    caller_locations(2, 10).find { |location| !location.path.end_with?('feed_lifecycle_logging.rb') }
  end

  module FeedManager
    def clean_feeds!(type, ids)
      ids = Array(ids)

      Custom::FeedLifecycleLogging.log_event(
        'feed_manager.clean_feeds',
        type: type,
        ids_count: ids.size,
        ids: ids.first(20).join(','),
        caller: Custom::FeedLifecycleLogging.feed_clean_caller
      )

      super
    end
  end

  module User
    def regenerate_feed!
      home_feed = ::HomeFeed.new(account)

      if home_feed.regenerating?
        Custom::FeedLifecycleLogging.log_event(
          'user.regenerate_feed.skipped',
          account_id: account_id,
          user_id: id,
          reason: 'already_regenerating',
          current_sign_in_at: current_sign_in_at&.iso8601,
          last_sign_in_at: last_sign_in_at&.iso8601
        )

        return super
      end

      Custom::FeedLifecycleLogging.log_event(
        'user.regenerate_feed.enqueued',
        account_id: account_id,
        user_id: id,
        current_sign_in_at: current_sign_in_at&.iso8601,
        last_sign_in_at: last_sign_in_at&.iso8601,
        signed_in_recently: signed_in_recently?
      )

      super
    end
  end

  module RegenerationWorker
    def perform(account_id, *args)
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      with_primary do
        @feed_lifecycle_logging_account = Account.find(account_id)
      end

      feed_size_before = ::FeedManager.instance.timeline_size(:home, @feed_lifecycle_logging_account.id)

      Custom::FeedLifecycleLogging.log_event(
        'regeneration_worker.started',
        account_id: @feed_lifecycle_logging_account.id,
        user_id: @feed_lifecycle_logging_account.user&.id,
        feed_size_before: feed_size_before,
        current_sign_in_at: @feed_lifecycle_logging_account.user&.current_sign_in_at&.iso8601,
        last_sign_in_at: @feed_lifecycle_logging_account.user&.last_sign_in_at&.iso8601
      )

      result = super

      feed_size_after = ::FeedManager.instance.timeline_size(:home, @feed_lifecycle_logging_account.id)
      duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round

      Custom::FeedLifecycleLogging.log_event(
        'regeneration_worker.finished',
        account_id: @feed_lifecycle_logging_account.id,
        user_id: @feed_lifecycle_logging_account.user&.id,
        feed_size_before: feed_size_before,
        feed_size_after: feed_size_after,
        duration_ms: duration_ms
      )

      result
    rescue ActiveRecord::RecordNotFound
      Custom::FeedLifecycleLogging.log_event(
        'regeneration_worker.skipped',
        account_id: account_id,
        reason: 'account_not_found'
      )

      true
    rescue => e
      Rails.logger.error do
        [
          'event=regeneration_worker.failed',
          "account_id=#{account_id}",
          "error_class=#{e.class}",
          "error_message=#{e.message.inspect}",
        ].join(' ')
      end

      raise
    end
  end

  module HomeTimelineController
    def show
      super
      log_empty_home_timeline if empty_initial_home_timeline_page?
    end

    private

    def empty_initial_home_timeline_page?
      defined?(@statuses) &&
        @statuses.empty? &&
        params.values_at(:max_id, :since_id, :min_id).all?(&:blank?)
    end

    def log_empty_home_timeline
      home_feed = ::HomeFeed.new(current_account)

      Custom::FeedLifecycleLogging.log_event(
        'home_timeline.empty',
        account_id: current_account.id,
        user_id: current_user.id,
        feed_size: ::FeedManager.instance.timeline_size(:home, current_account.id),
        regenerating: home_feed.regenerating?,
        current_sign_in_at: current_user.current_sign_in_at&.iso8601,
        last_sign_in_at: current_user.last_sign_in_at&.iso8601,
        signed_in_recently: current_user.signed_in_recently?
      )
    end
  end
end
