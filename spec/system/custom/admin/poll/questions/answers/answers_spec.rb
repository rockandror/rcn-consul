require "rails_helper"

describe "Answers", :admin do
  scenario "can destroy poll question answers when it has no related answers" do
    poll_question_answer = create(:poll_question_answer)

    visit admin_question_path(poll_question_answer.question)

    accept_confirm { click_button "Delete" }

    expect(page).to have_content("Poll question answer deleted successfully!")
  end

  scenario "cannot destroy poll question answers it has related answers" do
    poll_question_answer = create(:poll_question_answer)
    create(:poll_answer, question: poll_question_answer.question, answer: poll_question_answer)

    visit admin_question_path(poll_question_answer.question)

    accept_confirm { click_button "Delete" }

    expect(page).to have_content("Cannot delete poll question answer because it already has user answers!")
  end

  scenario "cannot destroy poll question answers it has related partial results" do
    poll_question_answer = create(:poll_question_answer)
    create(:poll_partial_result, question: poll_question_answer.question, answer: poll_question_answer)

    visit admin_question_path(poll_question_answer.question)

    accept_confirm { click_button "Delete" }

    expect(page).to have_content("Cannot delete poll question answer because it already has user answers!")
  end
end
