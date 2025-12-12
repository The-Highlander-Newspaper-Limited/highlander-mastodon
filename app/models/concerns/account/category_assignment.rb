# frozen_string_literal: true

module Account::CategoryAssignment
  extend ActiveSupport::Concern

  included do
    validate :poster_must_have_category, on: :update
  end

  private

  def poster_must_have_category
    return unless user&.poster?

    errors.add(:categories, :poster_role) if categories.empty?
  end
end
