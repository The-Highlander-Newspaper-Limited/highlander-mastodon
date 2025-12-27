# frozen_string_literal: true

# == Schema Information
#
# Table name: account_category_filters
#
#  id          :bigint(8)        not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :bigint(8)        not null
#  category_id :bigint(8)        not null
#
class AccountCategoryFilter < ApplicationRecord
  belongs_to :account, inverse_of: :account_category_filters
  belongs_to :category, inverse_of: :account_category_filters

  validates :category_id, uniqueness: { scope: :account_id }
  validate :cannot_filter_mandatory_category

  private

  def cannot_filter_mandatory_category
    errors.add(:category, :mandatory) if category&.mandatory_for_readers?
  end
end
