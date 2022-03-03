class SchoolCanOrderDevicesNotifications
  attr_reader :school, :notify_computacenter

  def initialize(school, notify_computacenter: true)
    @school = school
    @notify_computacenter = notify_computacenter
  end

  def call
    return unless school&.eligible_to_order?

    notify_users if school&.devices_available_to_order?
    email_computacenter_about_new_laptop_cap if notify_computacenter
  end

private

  def email_computacenter_about_new_laptop_cap
    ComputacenterMailer
      .with(school: school, new_cap_value: new_laptop_cap_value)
      .notify_of_school_can_order
      .deliver_later
  end

  def fe_wave?
    school.responsible_body.new_fe_wave?
  end

  def message_for_fe_college
    routers_only? ? :user_can_order_routers_in_fe_college : :user_can_order_in_fe_college
  end

  def message_for_non_fe_college
    routers_only? ? :user_can_order_routers : :user_can_order
  end

  def message_for_vcap
    routers_only? ? :user_can_order_routers_in_virtual_cap : :user_can_order_in_virtual_cap
  end

  def message_for(user)
    return :nudge_rb_to_add_school_contact if status?(nil, 'needs_contact') && rb_user?(user)
    return :user_can_order_but_action_needed if status?('needs_info', 'school_contacted') && org_user?(user)
    return :nudge_user_to_read_privacy_policy if status?('rb_can_order', 'school_can_order') && nudgeable_user?(user)
    return unless ordering_user?(user)
    return if routers_only? # 'Pause router only emails'
    return message_for_vcap if status?('rb_can_order') && school.responsible_body.vcap?
    return unless status?('ready', 'school_ready', 'rb_can_order', 'school_can_order')

    fe_wave? ? message_for_fe_college : message_for_non_fe_college
  end

  def new_laptop_cap_value
    school&.raw_cap(:laptop)
  end

  def notify_about_school_being_able_to_order
    relevant_users.each { |user| notify_user(user) }
  end

  def notify_support
    CanOrderDevicesMailer
      .with(school: school)
      .send(:notify_support_school_can_order_but_no_one_contacted)
      .deliver_later
  end

  def notify_users
    relevant_users.present? ? notify_about_school_being_able_to_order : notify_support
  end

  def notify_user(user)
    message_type = message_for(user) unless school.opted_out?
    return if message_type.blank?

    CanOrderDevicesMailer.with(user: user, school: school).send(message_type).deliver_later
    EventNotificationsService.broadcast(UserCanOrderEvent.new(user: user, school: school, type: message_type))
  end

  def nudgeable_user?(user)
    user.order_devices_for_school?(school) && !user.seen_privacy_notice?
  end

  def ordering_user?(user)
    user.in?(school.order_users_with_active_techsource_accounts)
  end

  def org_user?(user)
    user.in?(school.organisation_users)
  end

  def rb_user?(user)
    user.in?(school.rb_users)
  end

  def relevant_users
    @relevant_users ||= school.organisation_users.presence || school.rb_users
  end

  def routers_only?
    return @routers_only if instance_variable_defined?(:@routers_only)

    @routers_only = school.can_order_routers_only_right_now?
  end

  def status?(*statuses)
    school.preorder_status.in?(statuses)
  end
end
