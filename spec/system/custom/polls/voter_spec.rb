require "rails_helper"

describe "Voter" do
  context "Origin", :with_frozen_time do
    let(:poll) { create(:poll, :current) }
    let(:question) { create(:poll_question, poll: poll) }

    scenario "Voting via web - Standard" do
      Setting["feature.user.skip_verification"] = true
      login_as(create(:user))
      create(:poll_question_answer, question: question, title: "Yes")
      visit poll_path(poll)

      choose "Yes"
      click_button "Vote"

      expect(page).to have_content("Poll saved successfully!")
      expect(Poll::Voter.count).to eq(1)
      expect(Poll::Voter.first.origin).to eq("web")
    end
  end
end
