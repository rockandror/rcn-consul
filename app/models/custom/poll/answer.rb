require_dependency Rails.root.join("app", "models", "poll", "answer").to_s

class Poll::Answer
  belongs_to :answer, class_name: "Poll::Question::Answer", inverse_of: :answers

  skip_validation :answer, :presence
  skip_validation :answer, :inclusion

  validates :answer_id, presence: true, if: ->(a) { a.question&.single_choice? }
  validates :answer_id, inclusion: { in: ->(a) { a.question.question_answers.ids }},
                        if: ->(a) { a.question&.single_choice? }

  validates :open_answer, presence: true, unless: ->(a) { a.question&.single_choice? }

  def save_and_record_voter_participation(token = nil)
    transaction do
      touch if persisted?
      save!
      Poll::Voter.find_or_create_by!(user: author, poll: poll, origin: "web")
    end
  end
end
