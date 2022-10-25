require_dependency Rails.root.join("app", "models", "abilities", "administrator").to_s

class Abilities::Administrator
  alias_method :consul_initialize, :initialize

  def initialize(user)
    consul_initialize(user)

    can :destroy, Poll::Question::Answer do |answer|
      answer.answers.none? && answer.partial_results.none?
    end
    can :export, Poll, &:expired?
  end
end
