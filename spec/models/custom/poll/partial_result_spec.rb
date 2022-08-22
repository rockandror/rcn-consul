require "rails_helper"

describe Poll::PartialResult do
  describe "validations" do
    it "validates that the answers are included in the Poll::Question's list" do
      question = create(:poll_question)
      question_answer_1 = create(:poll_question_answer, title: "One", question: question)
      question_answer_2 = create(:poll_question_answer, title: "Two", question: question)
      question_answer_3 = create(:poll_question_answer, title: "Three", question: question)

      expect(build(:poll_partial_result, question: question, answer: question_answer_1)).to be_valid
      expect(build(:poll_partial_result, question: question, answer: question_answer_2)).to be_valid
      expect(build(:poll_partial_result, question: question, answer: question_answer_3)).to be_valid

      question_answer_4 = create(:poll_question_answer, title: "Four")
      expect(build(:poll_partial_result, question: question, answer: question_answer_4)).not_to be_valid
    end
  end
end
