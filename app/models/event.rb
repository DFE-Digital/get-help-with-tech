class Event
  attr_accessor :params

  def initialize(params)
    self.params = params
  end

  def notifiable?
    false
  end

  def message
    'an event happened'
  end

private

  def organisation_name(user)
    user.organisation_name
  end
end
