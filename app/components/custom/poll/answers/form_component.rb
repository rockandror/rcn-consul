class Poll::Answers::FormComponent < ApplicationComponent
  attr_reader :answers, :poll
  delegate :current_user, :cannot?, to: :helpers

  def initialize(poll, answers)
    @poll = poll
    @answers = answers
  end

  def error_message
    count = answers.select { |a| a.errors.any? }.map(&:errors).flatten.count

    I18n.t("polls.answers.form.error", count: count) if count > 0
  end
end
