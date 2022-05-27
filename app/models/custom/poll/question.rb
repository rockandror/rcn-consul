require_dependency Rails.root.join("app", "models", "poll", "question").to_s

class Poll::Question < ApplicationRecord
  VALIDATORS = %w[none age postal_code].freeze
  translates :description, touch: true
  globalize_accessors

  def single_choice?
    question_answers.any?
  end

  def postal_code_validator?
    validator == "postal_code"
  end

  def age_validator?
    validator == "age"
  end
end
