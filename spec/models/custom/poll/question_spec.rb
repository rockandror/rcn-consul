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

  describe "#postal_code_validator?" do
    it "returns false when question has no validator" do
      poll_question = create(:poll_question, validator: "none")

      expect(poll_question.postal_code_validator?).to be_falsy
    end

    it "returns true when question has postal_code validator" do
      poll_question = create(:poll_question, validator: "postal_code")

      expect(poll_question.postal_code_validator?).to be_truthy
    end
  end

  describe "#age_validator?" do
    it "returns false when question has no validator" do
      poll_question = create(:poll_question, validator: "none")

      expect(poll_question.age_validator?).to be_falsy
    end

    it "returns true when question has postal_code validator" do
      poll_question = create(:poll_question, validator: "age")

      expect(poll_question.age_validator?).to be_truthy
    end
  end
end
