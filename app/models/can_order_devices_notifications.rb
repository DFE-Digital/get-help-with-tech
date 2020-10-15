class CanOrderDevicesNotifications
  attr_reader :school, :user

  def initialize(school: nil, user: nil)
    @school = school
    @user = user
  end

  def call
    if school&.can_order_devices_right_now?
      notify_about_school_being_able_to_order
      notify_computacenter
    elsif user
      notify_user_about_all_schools_they_can_order_for
    end
    # TODO: if the school could order devices but cannot anymore, should somebody be notified?
  end

private

  def notify_about_school_being_able_to_order
    all_relevant_users = school.organisation_users.presence || school.responsible_body.users
    all_relevant_users.each do |user|
      message_type = what_message_to_send(school, user)
      next if message_type.blank?

      notify_user(
        user: user,
        school: school,
        message_type: message_type,
      )
    end
  end

  def notify_user_about_all_schools_they_can_order_for
    user.schools_i_order_for.select(&:can_order_devices_right_now?).each do |school|
      notify_user(user: user, school: school, message_type: :user_can_order)
    end
  end

  def what_message_to_send(school, user)
    if status?(nil, 'needs_contact', school: school) && user.in?(school.responsible_body.users)
      :nudge_rb_to_add_school_contact
    elsif status?('needs_info', 'school_contacted', school: school) && user.in?(school.organisation_users)
      :user_can_order_but_action_needed
    elsif status?('ready', 'school_ready', 'rb_can_order', 'school_can_order', school: school) && user.in?(school.order_users_with_active_techsource_accounts)
      :user_can_order
    end
  end

  def notify_computacenter
    if FeatureFlag.active?(:notify_can_place_orders)
      ComputacenterMailer
        .with(school: school, new_cap_value: new_cap_value)
        .notify_of_school_can_order
        .deliver_later
    end
  end

  def notify_users(users:, school:, message_type:)
    users.each do |user|
      notify_user(user: user, school: school, message_type: message_type)
    end
  end

  def notify_user(user:, school:, message_type:)
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

  def new_cap_value
    school&.std_device_allocation&.cap || 0
  end

  def status?(*statuses, school:)
    school.preorder_information&.status&.in?(statuses)
  end
end
