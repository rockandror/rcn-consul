require "rails_helper"

describe Poll::Answer do
  describe "validations" do
    describe "when question is open and is mandatory" do
      let(:question) { create(:poll_question, mandatory_answer: true) }

      it "is valid if open_answer is fullfilled" do
        expect(build(:poll_answer, question: question, open_answer: "Open Answer")).to be_valid
      end

      it "is not valid if open_answer is empty" do
        expect(build(:poll_answer, question: question, open_answer: "")).not_to be_valid
      end
    end

    describe "when question is open and is not mandatory" do
      let(:question) { create(:poll_question, mandatory_answer: false) }

      it "is valid if open_answer is fullfilled" do
        expect(build(:poll_answer, question: question, open_answer: "Open Answer")).to be_valid
      end

      it "is valid if open_answer is empty" do
        expect(build(:poll_answer, question: question, open_answer: "")).to be_valid
      end
    end

    describe "when question is single choice and mandatory" do
      let(:question) { create(:poll_question, :yes_no, mandatory_answer: true) }

      it "is valid if answer any answer was chosen" do
        expect(build(:poll_answer, answer: question.question_answers.sample, question: question)).to be_valid
      end

      it "is not valid if answer is empty" do
        expect(build(:poll_answer, answer: nil, question: question)).not_to be_valid
      end
    end

    describe "when question is single choice and not mandatory" do
      let(:question) { create(:poll_question, :yes_no, mandatory_answer: false) }

      it "is valid if answer is defined" do
        expect(build(:poll_answer, answer: question.question_answers.sample, question: question)).to be_valid
      end

      it "is valid if answer is empty" do
        expect(build(:poll_answer, answer: nil, question: question)).to be_valid
      end
    end

    it "is valid for answers included in the Poll::Question's question_answers list" do
      question = create(:poll_question)
      question_answer_1 = create(:poll_question_answer, title: "One", question: question)
      question_answer_2 = create(:poll_question_answer, title: "Two", question: question)
      question_answer_3 = create(:poll_question_answer, title: "Three", question: question)

      expect(build(:poll_answer, question: question, answer: question_answer_1)).to be_valid
      expect(build(:poll_answer, question: question, answer: question_answer_2)).to be_valid
      expect(build(:poll_answer, question: question, answer: question_answer_3)).to be_valid

      question_answer_4 = create(:poll_question_answer, title: "Three")
      expect(build(:poll_answer, question: question, answer: question_answer_4)).not_to be_valid
    end
  end

  describe "#save_and_record_voter_participation" do
    let(:author) { create(:user, :level_two) }
    let(:poll) { create(:poll) }
    let(:question) { create(:poll_question, :yes_no, poll: poll) }
    let(:yes) { question.question_answers.first }
    let(:no) { question.question_answers.last }

    it "creates a poll_voter with user and poll data" do
      answer = create(:poll_answer, question: question, author: author, answer: yes)
      expect(answer.poll.voters).to be_blank

      answer.save_and_record_voter_participation("token")
      expect(poll.reload.voters.size).to eq(1)
      voter = poll.voters.first

      expect(voter.document_number).to eq(answer.author.document_number)
      expect(voter.poll_id).to eq(answer.poll.id)
      expect(voter.officer_id).to eq(nil)
    end

    it "updates a poll_voter with user and poll data" do
      answer = create(:poll_answer, question: question, author: author, answer: yes)
      answer.save_and_record_voter_participation("token")

      expect(poll.reload.voters.size).to eq(1)

      answer = create(:poll_answer, question: question, author: author, answer: no)
      answer.save_and_record_voter_participation("token")

      expect(poll.reload.voters.size).to eq(1)

      voter = poll.voters.first
      expect(voter.document_number).to eq(answer.author.document_number)
      expect(voter.poll_id).to eq(answer.poll.id)
    end
  end
end
