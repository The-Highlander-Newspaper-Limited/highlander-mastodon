# frozen_string_literal: true

# == Schema Information
#
# Table name: account_category_notifications
#
#  id          :bigint(8)        not null, primary key
#  account_id  :bigint(8)        not null
#  category_id :bigint(8)        not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class AccountCategoryNotification < ApplicationRecord
  belongs_to :account, inverse_of: :account_category_notifications
  belongs_to :category, inverse_of: :account_category_notifications

  validates :category_id, uniqueness: { scope: :account_id }
end
