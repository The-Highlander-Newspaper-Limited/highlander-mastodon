# frozen_string_literal: true

module REST::Custom::AccountCategories
  extend ActiveSupport::Concern

  class CategorySerializer < ActiveModel::Serializer
    attributes :id, :name, :mandatory_for_readers
  end

  included do
    attribute :categories

    has_many :categories, serializer: CategorySerializer
  end

  def categories
    return [] if object.unavailable?

    object.categories.ordered
  end
end
