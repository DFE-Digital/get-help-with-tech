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
    message_type = what_message_to_send_about(school)

    if message_type.present?
      notify_users(
        users: which_users_to_send_message_to(school: school, message_type: message_type),
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

  def what_message_to_send_about(school)
    case school.preorder_information&.status
    when nil, 'needs_contact'
      :nudge_rb_to_add_school_contact
    when 'school_will_be_contacted'
      # This is on the DfE to onboard these schools - there is nothing users can do in this case
    when 'needs_info', 'school_contacted'
      :user_can_order_but_action_needed
    when 'ready', 'school_ready', 'rb_can_order', 'school_can_order'
      :user_can_order
    else
      raise "Unexpected preorder status #{school.preorder_information.status} for #{school.name} (#{school.urn})"
    end
  end

  def which_users_to_send_message_to(school:, message_type:)
    if message_type == :user_can_order
      # TODO: what if there aren't any order users with active accounts?
      school.order_users_with_active_techsource_accounts
    elsif message_type == :user_can_order_but_action_needed
      # TODO: what if there aren't any school organisation users?
      school.organisation_users
    elsif message_type == :nudge_rb_to_add_school_contact
      school.responsible_body.users
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
end
