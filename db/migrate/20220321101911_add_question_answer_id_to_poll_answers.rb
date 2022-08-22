class AddQuestionAnswerIdToPollAnswers < ActiveRecord::Migration[5.2]
  def change
    add_reference :poll_answers, :answer, index: true, foreign_key: { to_table: :poll_question_answers }
  end
end
