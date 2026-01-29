# frozen_string_literal: true

module ThemedLogoHelper
  def themed_logo(variant_class)
    content_tag(
      :span,
      class: "logo logo--img #{variant_class}",
      role: 'img',
      aria: { label: site_title }
    ) do
      safe_join(
        [
          image_tag(frontend_asset_path('images/highlander_H_black.svg'), alt: '', class: 'logo__img logo__img--light'),
          image_tag(frontend_asset_path('images/highlander_H_white.svg'), alt: '', class: 'logo__img logo__img--dark'),
        ]
      )
    end
  end
end
