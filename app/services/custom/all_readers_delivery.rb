# frozen_string_literal: true

module Custom::AllReadersDelivery
  # Override follower fan-out with delivery to all active readers
  def deliver_to_all_followers!
    return super unless @status.public_visibility?

    Account.joins(:user).merge(User.signed_in_recently).select(:id).reorder(nil).find_in_batches do |accounts|
      FeedInsertWorker.push_bulk(accounts) do |account|
        [@status.id, account.id, 'home', { 'update' => update? }]
      end
    end
  end
end
