class RemoveAnswerFromPollAnswers < ActiveRecord::Migration[5.2]
  def change
    remove_column :poll_answers, :answer, :string
  end
end
