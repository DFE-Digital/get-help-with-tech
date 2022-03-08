class CreateUserService
  def self.invite_responsible_body_user(user_params = {})
    if user_exists?(user_params)
      invite_existing_user_to_responsible_body!(user_params.merge({ rb_level_access: true }))
    else
      invite_new_user_to_responsible_body!(user_params.merge({ rb_level_access: true }))
    end
  end

  def self.invite_school_user(user_params = {})
    devolve_ordering_if_needed!(user_params)
    if user_exists_on_other_school?(user_params) || user_exists_as_responsible_body_user?(user_params)
      invite_to_additional_school!(user_params)
    else
      create_new_school_user!(user_params)
    end
  end

  def self.user_exists?(user_params)
    User.where(email_address: user_params[:email_address]).exists?
  end

  def self.user_exists_on_other_school?(user_params)
    user = User.find_by(email_address: user_params[:email_address])
    user && !user.school_ids.empty? && !user.school_ids.include?(user_params[:school_id])
  end

  def self.user_exists_as_responsible_body_user?(user_params)
    User.where(email_address: user_params[:email_address])
        .where.not(responsible_body_id: nil)
        .exists?
  end

  def self.create_new_school_user!(user_params)
    orders_devices = user_params[:orders_devices].presence || false
    user = User.new(user_params.merge(orders_devices: orders_devices))
    if user.save
      InviteSchoolUserMailer.with(user: user).nominated_contact_email.deliver_later
      user.school.refresh_preorder_status!
    end
    user
  end

  private_class_method :create_new_school_user!

  def self.invite_to_additional_school!(user_params)
    user = User.find_by_email_address(user_params[:email_address])
    school = School.find(user_params[:school_id])
    unless user.school_ids.include?(user_params[:school_id])
      user.schools << school
      AddAdditionalSchoolToExistingUserMailer.with(user: user, school: school).additional_school_email.deliver_later
      school.refresh_preorder_status!
      user.update!(user_params.select { |key, _value| user.send(key).blank? }.merge(deleted_at: nil))
    end
    user
  end

  private_class_method :invite_to_additional_school!

  def self.invite_existing_user_to_responsible_body!(user_params)
    user = User.find_by_email_address(user_params[:email_address])
    if user.responsible_body_id.present? && !user.soft_deleted?
      user.assign_attributes(user_params)
      user.errors.add(:base, :existing_responsible_body_user)
      user.errors.add(:email_address, :belongs_to_existing_responsible_body_user)
    elsif user.update(user_params.select { |key, _value| user.send(key).blank? }.merge(deleted_at: nil))
      InviteExistingUserToResponsibleBodyMailer.with(user: user, responsible_body: user.responsible_body).invite_existing_user_to_responsible_body_email.deliver_later
    end
    user
  end

  private_class_method :invite_existing_user_to_responsible_body!

  def self.invite_new_user_to_responsible_body!(user_params)
    user = User.new(user_params.merge(orders_devices: true))
    if user.save
      InviteResponsibleBodyUserMailer.with(user: user).invite_user_email.deliver_later
    end
    user
  end

  def self.devolve_ordering_if_needed!(user_params)
    school = School.find_by(id: user_params[:school_id])
    SchoolSetWhoManagesOrdersService.new(school, :school).call if school && school.who_will_order_devices.blank?
  end

  private_class_method :devolve_ordering_if_needed!
end
