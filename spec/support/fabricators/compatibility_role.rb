# frozen_string_literal: true

# Test-only helper: ensure newly created users get a compatibility role
# so specs that expect posting/interaction permissions don't fail.
#
# To disable this behavior in specific tests,
# add :skip_compatibility_role tag to a separate example or whole example group

if Rails.env.test?
  RSpec.configure do |config|
    config.add_setting :skip_compatibility_role, default: false
    config.around(:each, :skip_compatibility_role) do |example|
      config.skip_compatibility_role = true
      example.run
      config.skip_compatibility_role = false
    end
  end

  User.class_eval do
    before_validation :assign_role_for_tests_compatibility, on: :create

    private

    def assign_role_for_tests_compatibility
      return if RSpec.configuration.skip_compatibility_role || role_id.present?

      compatability_role = UserRole.find_or_create_by(name: 'Compatability Role') do |r|
        r.permissions_as_keys = %w(create_statuses reply_to_statuses fav_statuses reblog_statuses)
        r.position = -1
      end

      self.role = compatability_role
    end
  end
end
