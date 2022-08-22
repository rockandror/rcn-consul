require_dependency Rails.root.join("app", "models", "poll", "partial_result").to_s

class Poll::PartialResult
  belongs_to :answer, class_name: "Poll::Question::Answer", inverse_of: :partial_results

  skip_validation :answer, :inclusion

  validates :answer, inclusion: { in: ->(a) { a.question.question_answers }},
                     unless: ->(a) { a.question.blank? }
end
