# frozen_string_literal: true

# Provides a public hook for feed regeneration and ensures new users get a backfilled home feed
# It is used to trigger home feed regeneration when category filters are changed
module User::HomeFeedGeneration
  extend ActiveSupport::Concern

  def regenerate_home_feed!
    regenerate_feed!
  end

  private

  def prepare_new_user!
    super

    regenerate_feed!
  end
end
