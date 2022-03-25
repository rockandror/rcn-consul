require "rails_helper"

RSpec.describe Poll::Question, type: :model do
  let(:poll_question) { build(:poll_question) }

  describe "#single_choice?" do
    it "returns false when question has no question answers" do
      poll_question = create(:poll_question)

      expect(poll_question.single_choice?).to be_falsy
    end

    it "returns true when question has question answers" do
      poll_question = create(:poll_question, :yes_no)

      expect(poll_question.single_choice?).to be_truthy
    end
  end
end
