require "rails_helper"

describe "Admin booths assignments", :admin do
  describe "Show" do
    scenario "Results for a booth assignment" do
      poll = create(:poll)
      booth_assignment = create(:poll_booth_assignment, poll: poll)
      other_booth_assignment = create(:poll_booth_assignment, poll: poll)

      question_1 = create(:poll_question, :yes_no, poll: poll)

      question_2 = create(:poll_question, poll: poll)
      create(:poll_question_answer, title: "Today", question: question_2)
      create(:poll_question_answer, title: "Tomorrow", question: question_2)

      create(:poll_partial_result,
              booth_assignment: booth_assignment,
              question: question_1,
              answer: question_1.question_answers.first,
              amount: 11)

      create(:poll_partial_result,
              booth_assignment: booth_assignment,
              question: question_1,
              answer: question_1.question_answers.last,
              amount: 4)

      create(:poll_partial_result,
              booth_assignment: booth_assignment,
              question: question_2,
              answer: question_2.question_answers.first,
              amount: 5)

      create(:poll_partial_result,
              booth_assignment: booth_assignment,
              question: question_2,
              answer: question_2.question_answers.last,
              amount: 6)

      create(:poll_partial_result,
              booth_assignment: other_booth_assignment,
              question: question_1,
              answer: question_1.question_answers.first,
              amount: 9999)

      create(:poll_recount,
             booth_assignment: booth_assignment,
             white_amount: 21,
             null_amount: 44,
             total_amount: 66)

      create(:poll_recount,
             booth_assignment: other_booth_assignment,
             white_amount: 999,
             null_amount: 999,
             total_amount: 999)

      visit admin_poll_booth_assignment_path(poll, booth_assignment)

      click_link "Results"

      expect(page).to have_content(question_1.title)

      within("#question_#{question_1.id}_0_result") do
        expect(page).to have_content("Yes")
        expect(page).to have_content(11)
      end

      within("#question_#{question_1.id}_1_result") do
        expect(page).to have_content("No")
        expect(page).to have_content(4)
      end

      expect(page).to have_content(question_2.title)

      within("#question_#{question_2.id}_0_result") do
        expect(page).to have_content("Today")
        expect(page).to have_content(5)
      end

      within("#question_#{question_2.id}_1_result") do
        expect(page).to have_content("Tomorrow")
        expect(page).to have_content(6)
      end

      within("#white_results") { expect(page).to have_content("21") }
      within("#null_results") { expect(page).to have_content("44") }
      within("#total_results") { expect(page).to have_content("66") }
    end
  end
end
