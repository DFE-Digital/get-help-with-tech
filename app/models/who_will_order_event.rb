class WhoWillOrderEvent < Event
  def notifiable?
    FeatureFlag.active?(:who_will_order_slack_notifications)
  end

  def message
    I18n.t(
      message_key,
      scope: [:events],
      responsible_body: @params[:responsible_body].name,
    )
  end

private

  def message_key
    if schools_will_order?
      :schools_will_order_event
    else
      :responsible_body_will_order_event
    end
  end

  def schools_will_order?
    @params[:responsible_body].who_will_order_devices == 'schools'
  end
end
