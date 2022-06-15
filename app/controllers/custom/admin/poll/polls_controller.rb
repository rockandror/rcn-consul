require_dependency Rails.root.join("app", "controllers", "admin", "poll", "polls_controller").to_s

class Admin::Poll::PollsController < Admin::Poll::BaseController
  def show
    @poll = Poll.find(params[:id])

    respond_to do |format|
      format.html
      format.csv do
        send_data Poll::Question::Answer::Exporter.new(@poll).to_csv,
                  filename: "#{@poll.name.parameterize.underscore}_questions_answers.csv"
      end
    end
  end
end
