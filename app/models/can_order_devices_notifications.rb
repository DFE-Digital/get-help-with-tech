class CanOrderDevicesNotifications
  attr_reader :school, :user

  def initialize(school: nil, user: nil)
    @school = school
    @user = user
  end

  def call
    if school&.can_order_devices_right_now?
      notify_about_school_being_able_to_order
    elsif user
      notify_user_about_all_schools_they_can_order_for
    end
  end

private

  def notify_about_school_being_able_to_order
    status = school.preorder_information.status
    if status.in? %w[needs_info school_contacted]
      notify_all_organisation_users_that_action_is_needed
      notify_computacenter
    elsif status.in? %w[ready school_ready rb_can_order school_can_order]
      notify_all_order_users_with_active_techsource_accounts
      notify_computacenter
    end
    send_slack_notifications_for_users_who_can_order_right_now
  end

  def notify_all_order_users_with_active_techsource_accounts
    school.order_users_with_active_techsource_accounts.each do |user|
      notify_user_can_order(user: user, school: school)
    end
  end

  def notify_all_organisation_users_that_action_is_needed
    school.organisation_users.each do |user|
      notify_user_can_order_but_action_needed(user: user, school: school)
    end
  end

  def send_slack_notifications_for_users_who_can_order_right_now
    school.order_users_with_active_techsource_accounts.each do |user|
      EventNotificationsService.broadcast(UserCanOrderEvent.new(user: user, school: @school))
    end
  end

  def notify_user_about_all_schools_they_can_order_for
    user.schools_i_order_for.select(&:can_order_devices_right_now?).each do |school|
      notify_user_can_order(user: user, school: school)
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

  def notify_user_can_order(user:, school:)
    if FeatureFlag.active?(:notify_can_place_orders)
      CanOrderDevicesMailer
        .with(user: user, school: school)
        .user_can_order
        .deliver_later
    end
  end

  def notify_user_can_order_but_action_needed(user:, school:)
    if FeatureFlag.active?(:notify_can_place_orders)
      CanOrderDevicesMailer
        .with(user: user, school: school)
        .user_can_order_but_action_needed
        .deliver_later
    end
  end

  def new_cap_value
    school&.std_device_allocation&.cap || 0
  end
end
