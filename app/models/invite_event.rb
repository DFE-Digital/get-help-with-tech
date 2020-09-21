class InviteEvent < Event
  def message
    I18n.t(
      :invite_event,
      scope: [:events],
      organisation: organisation_name(@params[:user]),
    )
  end
end
