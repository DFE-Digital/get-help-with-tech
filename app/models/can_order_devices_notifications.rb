class CanOrderDevicesNotifications
  attr_reader :school

  def initialize(school:)
    @school = school
  end

  def call
    if school.can_order_devices_right_now?
      if FeatureFlag.active?(:notify_can_place_orders)
        notify_all_order_users_with_active_techsource_accounts
        notify_computacenter
      end

      send_slack_notifications_for_users_who_can_order_right_now
    end
  end

private

  def notify_all_order_users_with_active_techsource_accounts
    school.order_users_with_active_techsource_accounts.each do |user|
      CanOrderDevicesMailer
        .with(user: user, school: school)
        .notify_user_email
        .deliver_later
    end
  end

  def send_slack_notifications_for_users_who_can_order_right_now
    school.order_users_with_active_techsource_accounts.each do |user|
      EventNotificationsService.broadcast(UserCanOrderEvent.new(user: user, school: @school))
    end
  end

  def notify_computacenter
    ComputacenterMailer
      .with(school: school, new_cap_value: new_cap_value)
      .notify_of_school_can_order
      .deliver_later
  end

  def new_cap_value
    school&.std_device_allocation&.cap || 0
  end
end
