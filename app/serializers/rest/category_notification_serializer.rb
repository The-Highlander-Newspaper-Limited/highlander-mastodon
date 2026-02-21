# frozen_string_literal: true

class REST::CategoryNotificationSerializer < ActiveModel::Serializer
  attributes :id

  has_one :category, serializer: REST::Custom::AccountCategories::CategorySerializer

  def id
    object.id.to_s
  end
end
