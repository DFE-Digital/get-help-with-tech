class PreorderInformation < ApplicationRecord
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
    if school_will_order_devices? && school_contact.nil?
      'needs_contact'
    elsif school_will_order_devices? && school_contacted_at.nil?
      'school_will_be_contacted'
    elsif school_will_order_devices? && school_contacted_at.present? && !chromebook_information_complete?
      'school_contacted'
    elsif school_will_order_devices? && school_contacted_at.present? && chromebook_information_complete?
      'school_ready'
    elsif chromebook_information_complete?
      'ready'
    else
      'needs_info'
    end
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

  def update_chromebook_information_and_status!(params)
    update!(params)
    update!(status: infer_status)
  end

  def self.for_responsible_bodies_in_devices_pilot
    joins(school: :responsible_body).merge(ResponsibleBody.in_devices_pilot)
  end

  def invite_school_contact!
    new_user = school_contact&.to_user

    if new_user&.valid?
      transaction do
        new_user.save!
        InviteSchoolUserMailer.with(user: new_user).nominated_contact_email.deliver_later
        update!(school_contacted_at: Time.zone.now)
        update!(status: infer_status)
      end
      true
    else
      false
    end
  end

private

  def set_defaults
    self.status ||= infer_status
  end
end
