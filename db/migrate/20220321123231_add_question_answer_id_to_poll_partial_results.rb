class AddQuestionAnswerIdToPollPartialResults < ActiveRecord::Migration[5.2]
  def change
    add_reference :poll_partial_results, :answer, index: true,
      foreign_key: { to_table: :poll_question_answers }
  end
end
