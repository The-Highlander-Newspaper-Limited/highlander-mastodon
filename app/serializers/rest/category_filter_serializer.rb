# frozen_string_literal: true

class REST::CategoryFilterSerializer < ActiveModel::Serializer
  attributes :id, :created_at

  has_one :category, serializer: REST::Custom::AccountCategories::CategorySerializer

  def id
    object.id.to_s
  end
end
