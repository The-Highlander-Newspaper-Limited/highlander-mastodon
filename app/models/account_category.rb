# frozen_string_literal: true

# == Schema Information
#
# Table name: account_categories
#
#  id          :bigint(8)        not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :bigint(8)        not null
#  category_id :bigint(8)        not null
#

class AccountCategory < ApplicationRecord
  belongs_to :account, inverse_of: :account_categories
  belongs_to :category, inverse_of: :account_categories

  validates :account_id, uniqueness: { scope: :category_id }
end
