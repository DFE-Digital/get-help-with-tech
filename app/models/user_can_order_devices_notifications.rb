class UserCanOrderDevicesNotifications
  attr_reader :user

  def initialize(user: nil)
    @user = user
  end

  def call
    notify_user_about_all_schools_they_can_order_for
  end

private

  def notify_user_about_all_schools_they_can_order_for
    user.schools_i_order_for.select(&:can_order_devices_right_now?).each do |school|
      notify_user(user: user, school: school)
    end
  end

  def notify_user(user:, school:)
    if FeatureFlag.active?(:notify_can_place_orders)
      CanOrderDevicesMailer
        .with(user: user, school: school)
        .send(message_type)
        .deliver_later
      EventNotificationsService.broadcast(
        UserCanOrderEvent.new(user: user, school: school, type: message_type),
      )
    end
  end

  def message_type
    :user_can_order
  end
end
