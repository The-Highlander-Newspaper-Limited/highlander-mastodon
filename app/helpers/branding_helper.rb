# frozen_string_literal: true

module BrandingHelper
  include ThemedLogoHelper # (possible) TODO: refactor to use svg inline with css for colors (to reduce the changes diff)

  def logo_as_symbol(version = :icon)
    case version
    when :icon
      _logo_as_symbol_icon
    when :wordmark
      _logo_as_symbol_wordmark
    end
  end

  def _logo_as_symbol_wordmark
    themed_logo('logo--wordmark')
  end

  def _logo_as_symbol_icon
    themed_logo('logo--icon')
  end

  def render_logo
    logo_as_symbol(:icon)
  end
end
