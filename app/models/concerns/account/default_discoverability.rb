# frozen_string_literal: true

module Account::DefaultDiscoverability
  extend ActiveSupport::Concern

  included do
    before_create :set_default_discoverability
  end

  private

  def set_default_discoverability
    return unless user && discoverable.nil?

    user_has_role = !user.role.everyone?
    self.discoverable = user_has_role
    self.indexable = user_has_role
  end
end
