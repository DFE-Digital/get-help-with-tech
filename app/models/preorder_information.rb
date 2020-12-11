class PreorderInformation < ApplicationRecord
  has_paper_trail

  self.table_name = 'preorder_information'

  belongs_to :school
  belongs_to :school_contact, optional: true

  validates :status, presence: true

  enum status: {
    needs_contact: 'needs_contact',
    needs_info: 'needs_info',
    ready: 'ready',
    school_will_be_contacted: 'school_will_be_contacted',
    school_contacted: 'school_contacted',
    school_ready: 'school_ready',
    rb_can_order: 'rb_can_order',
    school_can_order: 'school_can_order',
    ordered: 'ordered',
  }

  enum who_will_order_devices: {
    school: 'school',
    responsible_body: 'responsible_body',
  }, _suffix: 'will_order_devices'

  def initialize(*args)
    super
    set_defaults
  end

  # If this method is added, we may need to update School::SchoolDetailsSummaryListComponent
  def infer_status
    if school_will_order_devices? && !any_school_users? && school_contact.nil?
      'needs_contact'
    elsif school_will_order_devices? && !any_school_users? && school_contact.present?
      'school_will_be_contacted'
    elsif school_will_order_devices? && any_school_users? && !chromebook_information_complete?
      'school_contacted'
    elsif school_will_order_devices? && any_school_users? && chromebook_information_complete?
      if school.can_order_devices_right_now?
        'school_can_order'
      elsif (school.std_device_allocation&.devices_ordered || 0).positive? # bug should do all device types
        'ordered'
      else
        'school_ready'
      end
    elsif chromebook_information_complete?
      if orders_managed_centrally? && school.can_order_devices_right_now?
        'rb_can_order'
      elsif orders_managed_centrally? && (school.std_device_allocation&.devices_ordered || 0).positive? # bug should do all device types
        'ordered'
      else
        'ready'
      end
    else
      'needs_info'
    end
  end

  def refresh_status!
    update!(status: infer_status)
  end

  def change_who_will_order_devices!(who)
    self.who_will_order_devices = who
    self.status = infer_status
    save!
  end

  def who_will_order_devices_label
    case who_will_order_devices
    when 'school'
      'School'
    when 'responsible_body'
      school.responsible_body.humanized_type.capitalize
    end
  end

  def school_contact=(value)
    super(value)
    self.status = infer_status
  end

  def orders_managed_centrally?
    who_will_order_devices == 'responsible_body'
  end

  # prevent edge case where the built-in (attribute name)? method allows
  # a value of 'no' to return will_need_chromebooks? as true (as it's not nil)
  def will_need_chromebooks?
    will_need_chromebooks == 'yes'
  end

  def chromebook_information_complete?
    if will_need_chromebooks == 'yes'
      school_or_rb_domain.present? && recovery_email_address.present?
    else
      will_need_chromebooks == 'no'
    end
  end

  def chromebook_info_still_needed?
    will_need_chromebooks.nil? || will_need_chromebooks == 'i_dont_know'
  end

  def update_chromebook_information_and_status!(params)
    update!(params)
    refresh_status!
  end

  def invite_school_contact!
    if school_contact.present?
      transaction do
        user = CreateUserService.invite_school_user(
          email_address: school_contact.email_address,
          full_name: school_contact.full_name,
          telephone: school_contact.phone_number,
          school_id: school_id,
          orders_devices: true,
        )
        if user.errors.empty?
          update!(school_contacted_at: Time.zone.now)
          update!(status: infer_status)
          true
        else
          false
        end
      end
    else
      false
    end
  end

private

  def any_school_users?
    school&.user_schools&.any?
  end

  def set_defaults
    self.status ||= infer_status
  end
end
