class Poll::Question::Answer::Exporter
  require "csv"

  def initialize(poll)
    @poll = poll
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @poll.voters.each do |voter|
        csv << csv_values(voter)
      end
    end
  end

  private

    def headers
      @poll.questions.order(:id).map(&:title)
    end

    def csv_values(voter)
      voter.user.poll_answers.order(:question_id).map do |answer|
        value_of(answer)
      end
    end

    def value_of(answer)
      if answer.question.single_choice?
        answer.answer&.title
      else
        answer.open_answer
      end
    end
end
