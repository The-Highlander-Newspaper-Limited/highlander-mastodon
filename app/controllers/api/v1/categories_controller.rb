# frozen_string_literal: true

class Api::V1::CategoriesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:accounts' }
  before_action :require_user!

  def index
    render json: Category.ordered, each_serializer: REST::Custom::AccountCategories::CategorySerializer
  end
end
