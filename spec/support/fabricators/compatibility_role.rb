# frozen_string_literal: true

# Test-only helper: ensure newly created users get a compatibility role
# so specs that expect posting/interaction permissions don't fail.
if Rails.env.test?
  User.class_eval do
    before_validation :assign_role_for_tests_compatibility, on: :create

    private

    def assign_role_for_tests_compatibility
      return if role_id.present?

      compatability_role = UserRole.find_or_create_by(name: 'Compatability Role') do |r|
        r.permissions_as_keys = %w(create_statuses reply_to_statuses fav_statuses reblog_statuses)
        r.position = -1
      end

      self.role = compatability_role
    end
  end
end
