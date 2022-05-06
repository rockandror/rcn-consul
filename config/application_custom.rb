module Consul
  class Application < Rails::Application
    config.i18n.available_locales = ["en", "nn"]
    config.i18n.default_locale = :nn
    config.i18n.fallbacks = {
      "en" => "en",
      "nn" => "en"
    }
  end
end
