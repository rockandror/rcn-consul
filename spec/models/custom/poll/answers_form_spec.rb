require "rails_helper"

describe Poll::AnswersForm do
  let(:poll_answers_form) { Poll::AnswersForm.new }
  let(:question) { create(:poll_question, mandatory_answer: true) }
  let(:valid_answer_to_question) { build(:poll_answer, question: question, open_answer: "My answer") }
  let(:invalid_answer_to_question) { build(:poll_answer, question: question, open_answer: "") }
  let(:single_choice_question) { create(:poll_question, :yes_no, mandatory_answer: true) }
  let(:valid_answer_to_single_choice_question) do
    build(:poll_answer, question: single_choice_question,
                        answer: single_choice_question.question_answers.sample)
  end

  describe "validations" do
    it "is valid when terms_of_service is accepted and answers are valid" do
      poll_answers_form.terms_of_service = "1"
      poll_answers_form.answers = [valid_answer_to_question, valid_answer_to_single_choice_question]

      expect(poll_answers_form).to be_valid
    end

    it "is not valid when terms_of_service is accepted but any answer is invalid" do
      poll_answers_form.terms_of_service = "1"
      poll_answers_form.answers = [invalid_answer_to_question, valid_answer_to_single_choice_question]

      expect(poll_answers_form).not_to be_valid
    end

    it "is not valid when terms_of_service is not accepted even with valid answers" do
      poll_answers_form.terms_of_service = "0"
      poll_answers_form.answers = [valid_answer_to_question, valid_answer_to_single_choice_question]

      expect(poll_answers_form).not_to be_valid
    end
  end
end
