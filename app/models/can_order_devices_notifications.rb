class CanOrderDevicesNotifications
  attr_reader :school

  def initialize(school:)
    @school = school
  end

  def call
    if FeatureFlag.active?(:notify_can_place_orders) && school.can_order_devices_right_now?
      school.order_users_with_active_techsource_accounts.each do |user|
        CanOrderDevicesMailer
          .with(user: user, school: school)
          .notify_user_email
          .deliver_later
      end
    end
  end
end
