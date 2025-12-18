# frozen_string_literal: true

module CategoriesHelper
  def category_badge(category)
    badge_variant = category.mandatory_for_readers? ? :mandatory : :regular
    css_class = "category-badge category-badge--#{badge_variant}"
    content_tag(:span, category.name, class: css_class)
  end
end
