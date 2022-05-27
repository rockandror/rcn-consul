require_dependency Rails.root.join("app", "models", "poll", "answer").to_s

class Poll::Answer
  belongs_to :answer, class_name: "Poll::Question::Answer", inverse_of: :answers

  skip_validation :answer, :presence
  skip_validation :answer, :inclusion

  validates :answer_id, presence: true,
                        if: ->(a) { a.question&.single_choice? && a.question.mandatory_answer? }
  validates :answer_id, inclusion: { in: ->(a) { a.question.question_answers.ids }},
                        if: ->(a) { a.question&.single_choice? },
                        allow_nil: true
  validates :open_answer, format: { with: /\d{4}\Z/,
                                    message: I18n.t("polls.answers.form.postal_code_validator") },
                          if: ->(a) { a.question&.postal_code_validator? },
                          allow_blank: true
  validates :open_answer, numericality: { only_integer: true, greater_than: 10, less_than: 120 },
                          if: ->(a) { a.question&.age_validator? },
                          allow_blank: true
  validates :open_answer, presence: true,
                          unless: ->(a) { a.question&.single_choice? },
                          if: ->(a) { a.question&.mandatory_answer? }

  def save_and_record_voter_participation(token = nil)
    transaction do
      touch if persisted?
      save!
      Poll::Voter.find_or_create_by!(user: author, poll: poll, origin: "web")
    end
  end
end
