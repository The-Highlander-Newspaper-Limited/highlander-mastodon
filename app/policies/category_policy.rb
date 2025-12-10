# frozen_string_literal: true

class CategoryPolicy < ApplicationPolicy
  def index?
    role.can?(:manage_categories)
  end

  def create?
    role.can?(:manage_categories)
  end

  def update?
    role.can?(:manage_categories)
  end

  def destroy?
    role.can?(:manage_categories)
  end
end
