require_dependency Rails.root.join("app", "models", "poll", "answer").to_s

class Poll::Answer
  belongs_to :answer, class_name: "Poll::Question::Answer", inverse_of: :answers

  skip_validation :answer, :inclusion

  validates :answer, inclusion: { in: ->(a) { a.question.question_answers }},
                     unless: ->(a) { a.question.blank? }
end
