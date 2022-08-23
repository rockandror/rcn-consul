class ErrorsComponent < ApplicationComponent
  attr_accessor :message

  def initialize(message)
    @message = message
  end

  def render?
    message.present?
  end
end
