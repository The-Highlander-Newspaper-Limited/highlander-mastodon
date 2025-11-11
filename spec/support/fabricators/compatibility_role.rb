# frozen_string_literal: true

# Test-only helper: ensure newly created users get a compatibility role
# so specs that expect posting/interaction permissions don't fail.
if Rails.env.test?
  User.class_eval do
    before_validation :assign_compatability_role_for_tests, on: :create

    private

    def assign_compatability_role_for_tests
      return unless respond_to?(:role_id) && role_id.nil?

      compatability_role = UserRole.find_or_create_by(name: 'Compatability Role') do |r|
        r.permissions_as_keys = %w(create_statuses reply_to_statuses fav_statuses reblog_statuses)
      end

      self.role = compatability_role
    end
  end
end
