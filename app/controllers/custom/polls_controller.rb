require_dependency Rails.root.join("app", "controllers", "polls_controller").to_s

class PollsController < ApplicationController
  has_orders %w[most_voted newest oldest], only: [:answer, :show]

  before_action :set_questions, only: [:answer, :show]
  before_action :set_answers, only: :answer
  before_action :set_question_answers, only: [:answer, :show]
  before_action :set_commentable, only: [:answer, :show]

  invisible_captcha only: [:answer], honeypot: :title

  def show
    @poll_answers_form = Poll::AnswersForm.new(answers: @questions.map do |question|
      Poll::Answer.find_or_initialize_by(question: question, author: current_user)
    end)
  end

  def answer
    if @poll_answers_form.valid?
      @poll_answers_form.save!
      redirect_to @poll, notice: t("polls.answers.create.success_notice")
    else
      render :show
    end
  end

  private

    def set_commentable
      @commentable = @poll
      @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    end

    def set_questions
      @questions = @poll.questions.for_render.sort_for_list
    end

    def set_question_answers
      @poll_questions_answers = Poll::Question::Answer.where(question: @questions).with_content
        .order(:given_order)
    end

    def set_answers
      answers = @questions.map do |question|
        Poll::Answer.find_or_initialize_by(question: question, author: current_user).tap do |answer|
          if question.single_choice?
            answer.answer_id = params.dig("question_#{question.id}", :answer_id)
          else
            answer.open_answer = params.dig("question_#{question.id}", :open_answer)
          end
        end
      end

      @poll_answers_form = Poll::AnswersForm.new(answers: answers, terms_of_service:
        params.dig("poll_answers_form", :terms_of_service))
    end
end
