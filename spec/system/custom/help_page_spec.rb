require "rails_helper"

describe "Help page" do
  scenario "renders the legislation help section link when the process is enabled" do
    Setting["feature.help_page"] = true
    Setting["process.legislation"] = true

    visit page_path("help")

    expect(page).to have_link "Processes", href: "#processes"
  end

  scenario "does not render the legislation help section link when the process is disabled" do
    Setting["feature.help_page"] = true
    Setting["process.legislation"] = nil

    visit page_path("help")

    expect(page).not_to have_link "Processes"
  end
end
