class WhoWillOrderEvent < Event
  def message
    I18n.t(
      message_key,
      scope: [:events],
      responsible_body: @params[:responsible_body].name,
    )
  end

private

  def message_key
    schools_will_order? ? :schools_will_order_event : :responsible_body_will_order_event
  end

  def schools_will_order?
    @params[:responsible_body].orders_managed_by_schools?
  end
end
