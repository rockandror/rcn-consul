class Poll::Answers::FieldsComponent < ApplicationComponent
  attr_reader :answer
  delegate :current_user, :cannot?, to: :helpers

  def initialize(answer)
    @answer = answer
  end

  def question
    answer.question
  end

  def errors_for(field)
    return unless answer.errors.include?(field)

    tag.small class: "form-error is-visible" do
      answer.errors.full_messages_for(field).join(", ")
    end
  end

  def styles
    classes = %w[question-answer-fields]
    classes << "single-choice" if answer.question.single_choice?
    classes.join(" ")
  end
end
