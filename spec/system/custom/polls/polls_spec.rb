require "rails_helper"

describe "Polls" do
  context "Show" do
    let(:poll) { create(:poll) }

    scenario "Question answers appear in the given order" do
      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, title: "First answer", question: question, given_order: 2)
      answer2 = create(:poll_question_answer, title: "Second answer", question: question, given_order: 1)

      visit poll_path(poll)

      expect(answer2.title).to appear_before(answer1.title)
    end

    scenario "Non-logged in users" do
      create(:poll_question, :yes_no, poll: poll)

      visit poll_path(poll)

      expect(page).to have_content("You must sign in or sign up to participate")
      expect(page).to have_field("Yes", disabled: true)
      expect(page).to have_field("No", disabled: true)
    end

    scenario "Show questions descriptions when defined" do
      poll = create(:poll)
      open_question = create(:poll_question, poll: poll, description: "Open question description")
      open_question_no_decription = create(:poll_question, poll: poll)
      single_choice_question = create(:poll_question, :yes_no, poll: poll,
        description: "Single choice question description")
      single_choice_question_no_description = create(:poll_question, :yes_no, poll: poll)

      visit poll_path(poll)

      within "#question_#{open_question.id}_answer_fields" do
        expect(page).to have_css("span.help-text", text: "Open question description")
      end
      within "#question_#{single_choice_question.id}_answer_fields" do
        expect(page).to have_css("span.help-text", text: "Single choice question description")
      end
      within "#question_#{open_question_no_decription.id}_answer_fields" do
        expect(page).not_to have_css("span.help-text")
      end
      within "#question_#{single_choice_question_no_description.id}_answer_fields" do
        expect(page).not_to have_css("span.help-text")
      end
    end

    scenario "Show answers descriptions fields when defined" do
      poll = create(:poll, answers_descriptions_link_text: "You can find the answer descriptions...",
                           answers_descriptions_title: "Answers descriptions for poll")
      question = create(:poll_question, poll: poll)
      create(:poll_question_answer, question: question, title: "Yes")

      visit poll_path(poll)

      expect(page).to have_content "You can find the answer descriptions..."
      expect(page).to have_link "Read more"
      expect(page).to have_content "Answers descriptions for poll"
    end
  end

  context "Answer" do
    let(:user) { create(:user) }

    before do
      Setting["feature.user.skip_verification"] = true
      login_as(user)
    end

    scenario "Disable form in expired polls" do
      expired_poll = create(:poll, :expired)

      create(:poll_question, :yes_no, poll: expired_poll)

      visit poll_path(expired_poll)

      expect(page).to have_field("Yes", disabled: true)
      expect(page).to have_field("No", disabled: true)
      expect(page).to have_button("Vote", disabled: true)
      expect(page).to have_content("This poll has finished")
    end

    scenario "Show form errors when any answer is invalid" do
      poll = create(:poll)
      open_question = create(:poll_question, poll: poll, mandatory_answer: true)
      single_choice_question = create(:poll_question, :yes_no, poll: poll, mandatory_answer: true)

      visit poll_path(poll)
      click_button "Vote"

      within "#question_#{open_question.id}_answer_fields" do
        expect(page).to have_content("can't be blank")
      end
      within "#question_#{single_choice_question.id}_answer_fields" do
        expect(page).to have_content("Answer can't be blank")
      end
    end

    scenario "Show fullfilled form when answers were saved successfully" do
      poll = create(:poll)
      open_question = create(:poll_question, poll: poll)
      single_choice_question = create(:poll_question, :yes_no, poll: poll)
      visit poll_path(poll)

      fill_in open_question.title, with: "Open answer to question 1"
      choose "Yes"
      click_button "Vote"

      expect(page).to have_content("You have already participated in this poll.")
      expect(page).to have_content("If you vote again it will be overwritten.")
      within "#question_#{open_question.id}_answer_fields" do
        expect(page).to have_field(open_question.title, with: "Open answer to question 1")
      end
      within "#question_#{single_choice_question.id}_answer_fields" do
        expect(page).to have_field("Yes", checked: true)
        expect(page).to have_field("No", checked: false)
      end
    end

    scenario "Users can answer the poll questions" do
      poll = create(:poll)
      create(:poll_question, :yes_no, poll: poll)
      visit poll_path(poll)

      choose "Yes"
      click_button "Vote"

      expect(page).to have_content("Poll saved successfully!")
      expect(page).to have_field("Yes", checked: true)
      expect(page).to have_field("No", checked: false)
    end

    scenario "Allow to update answers" do
      poll = create(:poll)
      open_question = create(:poll_question, poll: poll)
      single_choice_question = create(:poll_question, :yes_no, poll: poll)

      visit poll_path(poll)
      fill_in open_question.title, with: "Open answer"
      choose "Yes"
      click_button "Vote"

      within "#question_#{open_question.id}_answer_fields" do
        expect(page).to have_field(open_question.title, with: "Open answer")
      end
      within "#question_#{single_choice_question.id}_answer_fields" do
        expect(page).to have_field("Yes", checked: true)
        expect(page).to have_field("No", checked: false)
      end

      fill_in open_question.title, with: "Open answer update"
      choose "No"
      click_button "Vote"

      expect(page).to have_content("Poll saved successfully!")
      within "#question_#{open_question.id}_answer_fields" do
        expect(page).to have_field(open_question.title, with: "Open answer update")
      end
      within "#question_#{single_choice_question.id}_answer_fields" do
        expect(page).to have_field("Yes", checked: false)
        expect(page).to have_field("No", checked: true)
      end
    end

    scenario "Answer poll with invisible_captcha honeypot field", :no_js do
      poll = create(:poll)
      visit poll_path(poll)

      fill_in :title, with: "I am a bot"
      click_button "Vote"

      expect(page.status_code).to eq(200)
      expect(page.html).to be_empty
      expect(page).to have_current_path(answer_poll_path(poll))
    end

    scenario "Answer poll too fast" do
      poll = create(:poll)
      allow(InvisibleCaptcha).to receive(:timestamp_threshold).and_return(Float::INFINITY)
      visit poll_path(poll)

      click_button "Vote"

      expect(page).to have_content "Sorry, that was too quick! Please resubmit"
      expect(page).to have_current_path(poll_path(poll))
    end

    scenario "Shows errors on create" do
      poll = create(:poll)
      create(:poll_question, poll: poll, mandatory_answer: true)
      visit poll_path(poll)

      click_button "Vote"

      expect(page).to have_content "1 error prevented your answers from being saved. Please check the " \
                                   "marked field to know how to correct it:"
    end

    describe "Show validator errors" do
      scenario "for postal_code_validator" do
        poll = create(:poll)
        open_question = create(:poll_question, poll: poll, validator: "postal_code")

        visit poll_path(poll)
        fill_in open_question.title, with: "1234AAAA"
        click_button "Vote"

        within "#question_#{open_question.id}_answer_fields" do
          expect(page).to have_content("The postal code format is invalid. Allowed postal codes must " \
                                       "contain four digits.")
        end
      end

      scenario "for age_validator" do
        poll = create(:poll)
        open_question = create(:poll_question, poll: poll, validator: "age")

        visit poll_path(poll)
        fill_in open_question.title, with: "9"
        click_button "Vote"

        within "#question_#{open_question.id}_answer_fields" do
          expect(page).to have_content("must be greater than 10")
        end
      end
    end
  end
end
