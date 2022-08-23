class Poll::Answers::FormComponent < ApplicationComponent
  attr_reader :poll_answers_form, :poll
  delegate :current_user, :cannot?, to: :helpers

  def initialize(poll, poll_answers_form)
    @poll = poll
    @poll_answers_form = poll_answers_form
  end

  def error_message
    count = poll_answers_form.errors.count

    I18n.t("polls.answers.form.error", count: count) if count > 0
  end
end
