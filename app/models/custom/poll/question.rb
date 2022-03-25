require_dependency Rails.root.join("app", "models", "poll", "question").to_s

class Poll::Question < ApplicationRecord
  def single_choice?
    question_answers.any?
  end
end
