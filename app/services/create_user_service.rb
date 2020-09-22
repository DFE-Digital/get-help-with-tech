class CreateUserService
  def self.invite_responsible_body_user(user_params = {})
    user = User.new(user_params.merge(override_params))
    if user.save
      InviteResponsibleBodyUserMailer.with(user: user).invite_user_email.deliver_later
    end
    user
  end

  def self.invite_school_user(user_params = {})
    user = User.new(user_params.merge(override_params))
    if user.save
      InviteSchoolUserMailer.with(user: user).nominated_contact_email.deliver_later
    end
    user
  end

  def self.override_params
    { approved_at: Time.zone.now, orders_devices: true }
  end

  private_class_method :override_params
end
