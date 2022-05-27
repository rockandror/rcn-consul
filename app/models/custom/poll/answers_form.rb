class Poll::AnswersForm
  include ActiveModel::Validations

  attr_accessor :answers, :terms_of_service

  validates :terms_of_service, acceptance: true
  validate :validate_answers_and_collect_errors

  def initialize(answers: [], terms_of_service: nil)
    @answers = answers
    @terms_of_service = terms_of_service
  end

  def save!
    ActiveRecord::Base.transaction do
      answers.each(&:save_and_record_voter_participation)
    end
  end

  private

    def validate_answers_and_collect_errors
      answers.each(&:valid?)

      errors.add :answers, answers.select { |a| a.errors.any? }.map(&:errors)
    end
end
