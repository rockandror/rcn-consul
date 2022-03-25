require "rails_helper"

describe Poll::Answer do
  describe "validations" do
    describe "open answer" do
      it "is valid when open_answer is fullfilled and the question has no answers defined" do
        question = create(:poll_question)

        expect(build(:poll_answer, open_answer: "Open Answer", question: question)).to be_valid
      end

      it "is not valid when open_answer is empty and the question has no answers defined" do
        question = create(:poll_question)

        expect(build(:poll_answer, open_answer: "", question: question)).not_to be_valid
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
