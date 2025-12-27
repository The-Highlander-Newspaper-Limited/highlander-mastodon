# frozen_string_literal: true

# == Schema Information
#
# Table name: categories
#
#  id                    :bigint(8)        not null, primary key
#  description           :text
#  mandatory_for_readers :boolean          default(FALSE), not null
#  name                  :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class Category < ApplicationRecord
  has_many :account_categories, inverse_of: :category, dependent: :destroy
  has_many :accounts, through: :account_categories
  has_many :account_category_filters, inverse_of: :category, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(mandatory_for_readers: :desc, name: :asc) }
end
