class Event
  attr_accessor :params

  def initialize(params)
    self.params = params
  end

  def notifiable?
    FeatureFlag.active?(:slack_notifications)
  end

  def message
    'an event happened'
  end

private

  def organisation_name(user)
    user.school&.name || user.responsible_body&.name || user.mobile_network&.brand
  end
end
