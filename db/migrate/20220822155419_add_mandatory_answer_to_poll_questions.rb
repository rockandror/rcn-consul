class AddMandatoryAnswerToPollQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_questions, :mandatory_answer, :boolean, null: false, default: false
  end
end
