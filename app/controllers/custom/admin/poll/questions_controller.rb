require_dependency Rails.root.join("app", "controllers", "admin", "poll", "questions_controller").to_s

class Admin::Poll::QuestionsController < Admin::Poll::BaseController
  private

    def question_params
      attributes = [:poll_id, :question, :proposal_id, :mandatory_answer, :validator]
      params.require(:poll_question).permit(*attributes, translation_params(Poll::Question))
    end
end
