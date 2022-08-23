class AddOpenAnswerToPollAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_answers, :open_answer, :string
  end
end
