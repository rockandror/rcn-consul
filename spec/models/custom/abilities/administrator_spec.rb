require "rails_helper"
require "cancan/matchers"

describe Abilities::Administrator do
  subject(:ability) { Ability.new(user) }

  let(:user) { administrator.user }
  let(:administrator) { create(:administrator) }
  let(:other_user) { create(:user) }
  let(:poll_question_answer_with_answers) { create(:poll_question_answer) }
  let(:poll_question_answer_with_partial_results) { create(:poll_question_answer) }
  let(:current_poll) { create(:poll, :current) }
  let(:expired_poll) { create(:poll, :expired) }

  before do
    create(:poll_answer, question: poll_question_answer_with_answers.question,
                         answer: poll_question_answer_with_answers)
    create(:poll_partial_result, question: poll_question_answer_with_partial_results.question,
                                 answer: poll_question_answer_with_partial_results)
  end

  it { should be_able_to(:destroy, Poll::Question::Answer) }
  it { should_not be_able_to(:destroy, poll_question_answer_with_answers) }
  it { should_not be_able_to(:destroy, poll_question_answer_with_partial_results) }

  it { should_not be_able_to(:export, current_poll) }
  it { should be_able_to(:export, expired_poll) }
end
