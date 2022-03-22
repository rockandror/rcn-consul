require_dependency Rails.root.join("app", "controllers", "officing", "results_controller").to_s

class Officing::ResultsController < Officing::BaseController
  private

    def build_results
      @results = []

      params[:questions].each_pair do |question_id, results|
        question = @poll.questions.find(question_id)
        go_back_to_new if question.blank?

        results.each_pair do |answer_index, count|
          next if count.blank?

          answer = question.question_answers.find_by(given_order: answer_index.to_i + 1).title
          go_back_to_new if question.blank?

          partial_result = ::Poll::PartialResult.find_or_initialize_by(booth_assignment_id: @officer_assignment.booth_assignment_id,
                                                                       date: Date.current,
                                                                       question_id: question_id,
                                                                       answer: answer)
          partial_result.officer_assignment_id = @officer_assignment.id
          partial_result.amount = count.to_i
          partial_result.author = current_user
          partial_result.origin = "booth"
          @results << partial_result
        end
      end

      build_recounts
    end
end
