class InviteEvent < Event
  def notifiable?
    FeatureFlag.active?(:invite_slack_notifications)
  end

  def message
    I18n.t(
      :invite_event,
      scope: [:events],
      organisation: organisation_name(@params[:user]),
    )
  end
end
