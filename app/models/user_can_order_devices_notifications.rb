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
      notify_user(school: school)
    end
  end

  def notify_user(school:)
    message_type = message_type_for_school(school)

    return unless message_type

    CanOrderDevicesMailer
      .with(user: user, school: school)
      .send(message_type)
      .deliver_later
    EventNotificationsService.broadcast(
      UserCanOrderEvent.new(user: user, school: school, type: message_type),
    )
  end

  def message_type_for_school(school)
    if %w[rb_can_order].include?(school.preorder_information&.status) && school.responsible_body.has_virtual_cap_feature_flags?
      :user_can_order_in_virtual_cap
    elsif %w[rb_can_order school_can_order].include?(school.preorder_information&.status)
      if school.responsible_body.new_fe_wave?
        :user_can_order_in_fe_college
      else
        :user_can_order
      end
    elsif %w[needs_info].include?(school.preorder_information&.status)
      :user_can_order_but_action_needed
    end
  end
end
