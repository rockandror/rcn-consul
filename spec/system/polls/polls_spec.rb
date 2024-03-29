require "rails_helper"

describe "Polls" do
  context "Concerns" do
    it_behaves_like "notifiable in-app", :poll
  end

  describe "Index" do
    scenario "Shows description for open polls" do
      visit polls_path
      expect(page).not_to have_content "Description for open polls"

      create(:active_poll, description: "Description for open polls")

      visit polls_path
      expect(page).to have_content "Description for open polls"

      click_link "Expired"
      expect(page).not_to have_content "Description for open polls"
    end

    scenario "Polls can be listed" do
      visit polls_path
      expect(page).to have_content("There are no open votings")

      polls = create_list(:poll, 3, :with_image)

      visit polls_path

      polls.each do |poll|
        expect(page).to have_content(poll.name)
        expect(page).to have_css("img[alt='#{poll.image.title}']")
        expect(page).to have_link("Participate in this poll")
      end
    end

    scenario "Proposal polls won't be listed" do
      proposal = create(:proposal)
      _poll = create(:poll, related: proposal)

      visit polls_path
      expect(page).to have_content("There are no open votings")
    end

    scenario "Filtering polls" do
      create(:poll, name: "Current poll")
      create(:poll, :expired, name: "Expired poll")

      visit polls_path
      expect(page).to have_content("Current poll")
      expect(page).to have_link("Participate in this poll")
      expect(page).not_to have_content("Expired poll")

      visit polls_path(filter: "expired")
      expect(page).not_to have_content("Current poll")
      expect(page).to have_content("Expired poll")
      expect(page).to have_link("Poll ended")
    end

    scenario "Current filter is properly highlighted" do
      visit polls_path
      expect(page).not_to have_link("Open")
      expect(page).to have_link("Expired")

      visit polls_path(filter: "expired")
      expect(page).to have_link("Open")
      expect(page).not_to have_link("Expired")
    end

    scenario "Displays icon correctly" do
      create_list(:poll, 3)

      visit polls_path

      expect(page).to have_css(".not-logged-in", count: 3)
      expect(page).to have_content("You must sign in or sign up to participate")

      user = create(:user)
      login_as(user)

      visit polls_path

      expect(page).to have_css(".unverified", count: 3)
      expect(page).to have_content("You must verify your account to participate")
    end

    scenario "Geozone poll" do
      create(:poll, geozone_restricted: true)

      login_as(create(:user, :level_two))
      visit polls_path

      expect(page).to have_css(".cant-answer", count: 1)
      expect(page).to have_content("This poll is not available on your geozone")
    end

    scenario "Already participated in a poll", :consul do
      poll_with_question = create(:poll)
      question = create(:poll_question, :yes_no, poll: poll_with_question)

      login_as(create(:user, :level_two))
      visit polls_path

      vote_for_poll_via_web(poll_with_question, question, "Yes")

      visit polls_path

      expect(page).to have_css(".already-answer", count: 1)
      expect(page).to have_content("You already have participated in this poll")
    end

    scenario "Poll title link to stats if enabled" do
      poll = create(:poll, :expired, name: "Poll with stats", stats_enabled: true)

      visit polls_path(filter: "expired")

      expect(page).to have_link("Poll with stats", href: stats_poll_path(poll.slug))
    end

    scenario "Poll title link to results if enabled" do
      poll = create(:poll, :expired, name: "Poll with results", stats_enabled: true, results_enabled: true)

      visit polls_path(filter: "expired")

      expect(page).to have_link("Poll with results", href: results_poll_path(poll.slug))
    end

    scenario "Shows SDG tags when feature is enabled" do
      Setting["feature.sdg"] = true
      Setting["sdg.process.polls"] = true

      create(:poll, sdg_goals: [SDG::Goal[1]], sdg_targets: [SDG::Target["1.1"]])

      visit polls_path

      expect(page).to have_selector "img[alt='1. No Poverty']"
      expect(page).to have_content "target 1.1"
    end
  end

  context "Show" do
    let(:geozone) { create(:geozone) }
    let(:poll) { create(:poll, summary: "Summary", description: "Description") }

    scenario "Visit path with id" do
      visit poll_path(poll.id)
      expect(page).to have_current_path(poll_path(poll.id))
    end

    scenario "Visit path with slug" do
      visit poll_path(poll.slug)
      expect(page).to have_current_path(poll_path(poll.slug))
    end

    scenario "Show answers with videos" do
      create(:poll_answer_video, poll: poll, title: "Awesome video", url: "youtube.com/watch?v=123")

      visit poll_path(poll)

      expect(page).to have_link("Awesome video", href: "youtube.com/watch?v=123")
    end

    scenario "Lists questions from proposals as well as regular ones" do
      normal_question = create(:poll_question, poll: poll)
      proposal_question = create(:poll_question, poll: poll, proposal: create(:proposal))

      visit poll_path(poll)
      expect(page).to have_content(poll.name)
      expect(page).to have_content(poll.summary)
      expect(page).to have_content(poll.description)

      expect(page).to have_content(normal_question.title)
      expect(page).to have_content(proposal_question.title)
    end

    scenario "Questions appear by created at order" do
      question = create(:poll_question, poll: poll, title: "First question")
      create(:poll_question, poll: poll, title: "Second question")
      create(:poll_question, poll: poll, title: "Third question")

      question.update!(title: "First question edited")

      visit polls_path

      expect("First question edited").to appear_before("Second question")
      expect("Second question").to appear_before("Third question")

      visit poll_path(poll)

      expect("First question edited").to appear_before("Second question")
      expect("Second question").to appear_before("Third question")
    end

    scenario "Question answers appear in the given order", :consul do
      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, title: "First", question: question, given_order: 2)
      answer2 = create(:poll_question_answer, title: "Second", question: question, given_order: 1)

      visit poll_path(poll)

      within("div#poll_question_#{question.id}") do
        expect(answer2.title).to appear_before(answer1.title)
      end
    end

    scenario "More info answers appear in the given order" do
      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, title: "First", question: question, given_order: 2)
      answer2 = create(:poll_question_answer, title: "Second", question: question, given_order: 1)

      visit poll_path(poll)

      within("div.poll-more-info-answers") do
        expect(answer2.title).to appear_before(answer1.title)
      end
    end

    scenario "Do not show answers without more information at more information section" do
      question = create(:poll_question, poll: poll)
      answer_with_description = create(:poll_question_answer, title: "Description", question: question,
        given_order: 1)
      answer_with_image = create(:poll_question_answer, :with_image, title: "Image", question: question,
        given_order: 2)
      answer_with_document = create(:poll_question_answer, :with_document, title: "Document",
        question: question, given_order: 3)
      answer_with_video = create(:poll_question_answer, :with_video, title: "Video", question: question,
        given_order: 4,)
      answer_empty = create(:poll_question_answer, title: "Empty", question: question, given_order: 5,
        description: nil, images: [], documents: [], videos: [])

      visit poll_path(poll)

      within("div.poll-more-info-answers") do
        expect(page).to have_content(answer_with_description.title)
        expect(page).to have_content(answer_with_image.title)
        expect(page).to have_content(answer_with_document.title)
        expect(page).to have_content(answer_with_video.title)
        expect(page).not_to have_content(answer_empty.title)
      end
    end

    scenario "Answer images are shown" do
      question = create(:poll_question, :yes_no, poll: poll)
      create(:image, imageable: question.question_answers.first, title: "The yes movement")

      visit poll_path(poll)

      expect(page).to have_css "img[alt='The yes movement']"
    end

    scenario "Buttons to slide through images work back and forth" do
      question = create(:poll_question, :yes_no, poll: poll)
      create(:image, imageable: question.question_answers.last, title: "The no movement")
      create(:image, imageable: question.question_answers.last, title: "No movement planning")

      visit poll_path(poll)

      within(".orbit-bullets") do
        find("[data-slide='1']").click

        expect(page).to have_css ".is-active[data-slide='1']"

        find("[data-slide='0']").click

        expect(page).to have_css ".is-active[data-slide='0']"
      end
    end

    scenario "Non-logged in users", :consul do
      create(:poll_question, :yes_no, poll: poll)

      visit poll_path(poll)

      expect(page).to have_content("You must sign in or sign up to participate")
      expect(page).to have_link("Yes", href: new_user_session_path)
      expect(page).to have_link("No", href: new_user_session_path)
    end

    scenario "Level 1 users", :consul do
      visit polls_path
      expect(page).not_to have_selector(".already-answer")

      poll.update!(geozone_restricted: true)
      poll.geozones << geozone

      create(:poll_question, :yes_no, poll: poll)

      login_as(create(:user, geozone: geozone))
      visit poll_path(poll)

      expect(page).to have_content("You must verify your account in order to answer")

      expect(page).to have_link("Yes", href: verification_path)
      expect(page).to have_link("No", href: verification_path)
    end

    scenario "Level 2 users in an expired poll", :consul do
      expired_poll = create(:poll, :expired, geozone_restricted: true)
      expired_poll.geozones << geozone

      question = create(:poll_question, :yes_no, poll: expired_poll)

      login_as(create(:user, :level_two, geozone: geozone))

      visit poll_path(expired_poll)

      within("#poll_question_#{question.id}_answers") do
        expect(page).to have_content("Yes")
        expect(page).to have_content("No")
        expect(page).not_to have_link("Yes")
        expect(page).not_to have_link("No")
      end
      expect(page).to have_content("This poll has finished")
    end

    scenario "Level 2 users in a poll with questions for a geozone which is not theirs", :consul do
      poll.update!(geozone_restricted: true)
      poll.geozones << create(:geozone)

      question = create(:poll_question, :yes_no, poll: poll)

      login_as(create(:user, :level_two))

      visit poll_path(poll)

      within("#poll_question_#{question.id}_answers") do
        expect(page).to have_content("Yes")
        expect(page).to have_content("No")
        expect(page).not_to have_link("Yes")
        expect(page).not_to have_link("No")
      end
    end

    scenario "Level 2 users reading a same-geozone poll", :consul do
      poll.update!(geozone_restricted: true)
      poll.geozones << geozone

      question = create(:poll_question, :yes_no, poll: poll)

      login_as(create(:user, :level_two, geozone: geozone))
      visit poll_path(poll)

      within("#poll_question_#{question.id}_answers") do
        expect(page).to have_link("Yes")
        expect(page).to have_link("No")
      end
    end

    scenario "Level 2 users reading a all-geozones poll", :consul do
      question = create(:poll_question, :yes_no, poll: poll)

      login_as(create(:user, :level_two))
      visit poll_path(poll)

      within("#poll_question_#{question.id}_answers") do
        expect(page).to have_link("Yes")
        expect(page).to have_link("No")
      end
    end

    scenario "Level 2 users who have already answered", :consul do
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

    scenario "Level 2 users answering", :consul do
      poll.update!(geozone_restricted: true)
      poll.geozones << geozone

      question = create(:poll_question, :yes_no, poll: poll)
      user = create(:user, :level_two, geozone: geozone)

      login_as user
      visit poll_path(poll)

      within("#poll_question_#{question.id}_answers") do
        click_link "Yes"

        expect(page).not_to have_link("Yes")
        expect(page).to have_link("No")
      end
    end

    scenario "Level 2 users changing answer", :consul do
      poll.update!(geozone_restricted: true)
      poll.geozones << geozone

      question = create(:poll_question, :yes_no, poll: poll)
      user = create(:user, :level_two, geozone: geozone)

      login_as user
      visit poll_path(poll)

      within("#poll_question_#{question.id}_answers") do
        click_link "Yes"

        expect(page).not_to have_link("Yes")
        expect(page).to have_link("No")

        click_link "No"

        expect(page).not_to have_link("No")
        expect(page).to have_link("Yes")
      end
    end

    scenario "Level 2 votes, signs out, signs in, votes again", :consul do
      poll.update!(geozone_restricted: true)
      poll.geozones << geozone

      question = create(:poll_question, :yes_no, poll: poll)
      user = create(:user, :level_two, geozone: geozone)

      login_as user
      visit poll_path(poll)

      within("#poll_question_#{question.id}_answers") do
        click_link "Yes"

        expect(page).not_to have_link("Yes")
        expect(page).to have_link("No")
      end

      click_link "Sign out"
      login_as user
      visit poll_path(poll)
      within("#poll_question_#{question.id}_answers") do
        click_link "Yes"

        expect(page).not_to have_link("Yes")
        expect(page).to have_link("No")
      end

      click_link "Sign out"
      login_as user
      visit poll_path(poll)
      within("#poll_question_#{question.id}_answers") do
        click_link "No"

        expect(page).not_to have_link("No")
        expect(page).to have_link("Yes")
      end
    end

    scenario "Shows SDG tags when feature is enabled" do
      Setting["feature.sdg"] = true
      Setting["sdg.process.polls"] = true

      poll = create(:poll, sdg_goals: [SDG::Goal[1]], sdg_targets: [SDG::Target["1.1"]])

      visit poll_path(poll)

      expect(page).to have_selector "img[alt='1. No Poverty']"
      expect(page).to have_content "target 1.1"
    end

    scenario "Polls with users same-geozone listed first" do
      create(:poll, geozone_restricted: true, name: "A Poll")
      create(:poll, name: "Not restricted")
      create(:poll, geozone_restricted: true, geozones: [geozone], name: "Geozone Poll")

      login_as(create(:user, :level_two, geozone: geozone))
      visit polls_path(poll)

      expect("Not restricted").to appear_before("Geozone Poll")
      expect("Geozone Poll").to appear_before("A Poll")
    end
  end

  context "Booth & Website", :with_frozen_time do
    let(:poll) { create(:poll, summary: "Summary", description: "Description") }
    let(:booth) { create(:poll_booth) }
    let(:officer) { create(:poll_officer) }

    scenario "Already voted on booth cannot vote on website", :consul do
      create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :vote_collection)
      create(:poll_officer_assignment, officer: officer, poll: poll, booth: booth, date: Date.current)
      question = create(:poll_question, :yes_no, poll: poll)
      user = create(:user, :level_two, :in_census)

      login_as(officer.user)
      visit new_officing_residence_path
      officing_verify_residence
      click_button "Confirm vote"

      expect(page).to have_content "Vote introduced!"

      visit new_officing_residence_path
      click_link "Sign out"
      login_as user
      visit poll_path(poll)

      expect(page).to have_content "You have already participated in a physical booth. You can not participate again."

      within("#poll_question_#{question.id}_answers") do
        expect(page).to have_content("Yes")
        expect(page).to have_content("No")

        expect(page).not_to have_link("Yes")
        expect(page).not_to have_link("No")
      end
    end
  end

  context "Results and stats" do
    scenario "Show poll results and stats if enabled and poll expired" do
      poll = create(:poll, :expired, results_enabled: true, stats_enabled: true)
      user = create(:user)

      login_as user
      visit poll_path(poll)

      expect(page).to have_content("Poll results")
      expect(page).to have_content("Participation statistics")

      visit results_poll_path(poll)
      expect(page).to have_content("Questions")

      visit stats_poll_path(poll)

      expect(page).to have_content("Participation data")
      expect(page).not_to have_content "Advanced statistics"
    end

    scenario "Advanced stats enabled" do
      poll = create(:poll, :expired, stats_enabled: true, advanced_stats_enabled: true)

      visit stats_poll_path(poll)

      expect(page).to have_content "Participation data"
      expect(page).to have_content "Advanced statistics"
    end

    scenario "Don't show poll results and stats if not enabled" do
      poll = create(:poll, :expired, results_enabled: false, stats_enabled: false)
      user = create(:user)

      login_as user
      visit poll_path(poll)

      expect(page).not_to have_content("Poll results")
      expect(page).not_to have_content("Participation statistics")

      visit results_poll_path(poll)
      expect(page).to have_content("You do not have permission to carry out the action 'results' on Poll.")

      visit stats_poll_path(poll)
      expect(page).to have_content("You do not have permission to carry out the action 'stats' on Poll.")
    end

    scenario "Do not show poll results or stats to admins if disabled", :admin do
      poll = create(:poll, :expired, results_enabled: false, stats_enabled: false)

      visit poll_path(poll)

      expect(page).not_to have_content("Poll results")
      expect(page).not_to have_content("Participation statistics")
    end

    scenario "Don't show poll results and stats if is not expired" do
      poll = create(:poll, :current, results_enabled: true, stats_enabled: true)
      user = create(:user)

      login_as user
      visit poll_path(poll)

      expect(page).not_to have_content("Poll results")
      expect(page).not_to have_content("Participation statistics")

      visit results_poll_path(poll)
      expect(page).to have_content("You do not have permission to carry out the action 'results' on Poll.")

      visit stats_poll_path(poll)
      expect(page).to have_content("You do not have permission to carry out the action 'stats' on Poll.")
    end

    scenario "Generates navigation links for polls without a slug" do
      poll = create(:poll, :expired, results_enabled: true, stats_enabled: true)
      poll.update_column(:slug, nil)

      visit poll_path(poll)

      expect(page).to have_link "Participation statistics"
      expect(page).to have_link "Poll results"

      click_link "Poll results"

      expect(page).to have_link "Information"
    end
  end
end
