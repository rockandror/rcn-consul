require_dependency Rails.root.join("app", "controllers", "admin", "poll", "results_controller").to_s

class Admin::Poll::ResultsController < Admin::Poll::BaseController
  authorize_resource class: "Poll"

  def export
    send_data Poll::Question::Answer::Exporter.new(@poll).to_csv,
              filename: "#{@poll.name.parameterize.underscore}_questions_answers.csv"
  end
end
