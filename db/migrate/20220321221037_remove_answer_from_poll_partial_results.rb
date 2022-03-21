class RemoveAnswerFromPollPartialResults < ActiveRecord::Migration[5.2]
  def change
    remove_column :poll_partial_results, :answer, :string
  end
end
