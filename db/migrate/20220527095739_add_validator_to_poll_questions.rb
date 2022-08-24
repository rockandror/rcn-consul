class AddValidatorToPollQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_questions, :validator, :string
  end
end
