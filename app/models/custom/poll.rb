require_dependency Rails.root.join("app", "models", "poll").to_s

class Poll < ApplicationRecord
  translates :answers_descriptions_link_text, touch: true
  translates :answers_descriptions_title, touch: true
  globalize_accessors
end
