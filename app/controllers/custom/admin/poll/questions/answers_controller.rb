require_dependency Rails.root.join("app", "controllers", "admin", "poll", "questions", "answers_controller").to_s

class Admin::Poll::Questions::AnswersController < Admin::Poll::BaseController
  skip_before_action :load_answer
  before_action :load_answer, only: [:show, :edit, :update, :documents, :destroy]

  def destroy
    if can?(:destroy, @answer)
      @answer.destroy!
      redirect_to admin_question_path(@answer.question),
        notice: t("flash.actions.destroy.poll_question_answer.success")
    else
      redirect_to admin_question_path(@answer.question),
        alert: t("flash.actions.destroy.poll_question_answer.error")
    end
  end
end
