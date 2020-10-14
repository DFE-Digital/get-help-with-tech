class UserCanOrderEvent < Event
  def message
    I18n.t(
      :user_can_order_event,
      scope: [:events],
      school: @params[:school].name,
    )
  end
end
