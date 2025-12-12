# frozen_string_literal: true

module User::CategoryAssignment
  extend ActiveSupport::Concern

  included do
    after_create :assign_new_poster_category, if: :poster?
    after_update :assign_new_poster_category, if: :became_poster?
  end

  def poster?
    role&.name == 'Poster'
  end

  private

  def became_poster?
    saved_change_to_role_id? && poster?
  end

  def assign_new_poster_category
    return if account.blank?

    new_poster_category = Category.find_by(name: 'New Poster')
    return if new_poster_category.blank? || account.categories.exists?(new_poster_category.id)

    account.categories << new_poster_category
  end
end
