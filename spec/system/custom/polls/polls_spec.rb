require "rails_helper"

describe "Polls" do
  context "Show" do
    let(:geozone) { create(:geozone) }
    let(:poll) { create(:poll, summary: "Summary", description: "Description") }

    scenario "Level 2 users who have already answered" do
      question = create(:poll_question, :yes_no, poll: poll)
      no = question.question_answers.last
      user = create(:user, :level_two)
      create(:poll_answer, question: question, author: user, answer: no)

      login_as user
      visit poll_path(poll)

      within("#poll_question_#{question.id}_answers") do
        expect(page).to have_link("Yes")
        expect(page).to have_link("No")
      end
    end
  end
end
