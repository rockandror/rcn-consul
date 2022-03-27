require "rails_helper"

describe "Admin poll questions", :admin do
  scenario "Create with optional answer" do
    poll = create(:poll, name: "Movies")
    title = "Star Wars: Episode IV - A New Hope"

    visit admin_poll_path(poll)
    click_link "Create question"

    expect(page).to have_content("Create question to poll Movies")
    expect(page).to have_selector("input[id='poll_question_poll_id'][value='#{poll.id}']",
                                   visible: :hidden)
    fill_in "Question", with: title

    click_button "Save"

    expect(page).to have_content(title)

    click_link "Edit question"

    expect(page).to have_field("Mandatory answer", checked: false)
  end

  scenario "Create with mandatory answer" do
    poll = create(:poll, name: "Movies")
    title = "Star Wars: Episode IV - A New Hope"

    visit admin_poll_path(poll)
    click_link "Create question"

    fill_in "Question", with: title
    check "Mandatory answer"

    click_button "Save"

    expect(page).to have_content(title)

    click_link "Edit question"

    expect(page).to have_checked_field("Mandatory answer")
  end
end
