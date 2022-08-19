unless Rails.env.test?
  apple_touch_icon = SiteCustomization::Image.find_or_create_by!(name: "apple-touch-icon-200")
  image = File.open(Rails.root.join("app", "assets", "images", "custom", "rcn-apple-touch-icon-200.png"))
  apple_touch_icon.image.attach(io: image, filename: "apple-touch-icon-200.png", content_type: "image/png")

  logo_email = SiteCustomization::Image.find_or_create_by!(name: "logo_email")
  image = File.open(Rails.root.join("app", "assets", "images", "custom", "rcn-logo-email.png"))
  logo_email.image.attach(io: image, filename: "rcn-logo-email.png", content_type: "image/png")
end
