# frozen_string_literal: true

module Custom::CategoryNotifications
  private

  def notify?(filter_result)
    return false if @type != :home || @status.reblog? || (@status.reply? && @status.in_reply_to_account_id != @status.account_id) ||
                    filter_result == :filter

    follow_notify = Follow.find_by(account: @follower, target_account: @status.account)&.notify?
    return true if follow_notify

    category_notifications_enabled?
  end

  def category_notifications_enabled?
    category_ids = @status.account&.category_ids
    return false if category_ids.blank?

    AccountCategoryNotification.exists?(account_id: @follower.id, category_id: category_ids)
  end
end
