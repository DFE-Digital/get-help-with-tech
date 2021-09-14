class PreorderInformation < ApplicationRecord
  has_paper_trail

  self.table_name = 'preorder_information'

  belongs_to :school
  belongs_to :school_contact, optional: true

  validates :status, presence: true

  before_save :check_and_update_status_if_necessary
  after_touch :refresh_status!

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
      elsif school.has_ordered?
        'ordered'
      else
        'school_ready'
      end
    elsif chromebook_information_complete?
      if responsible_body_will_order_devices? && school.can_order_devices_right_now?
        'rb_can_order'
      elsif responsible_body_will_order_devices? && school.has_ordered?
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

  def school_contact=(value)
    super(value)
    self.status = infer_status
  end

  def will_need_chromebooks?
    will_need_chromebooks == 'yes'
  end

  def will_not_need_chromebooks?
    will_need_chromebooks == 'no'
  end

  def chromebook_information_complete?
    # if we remove the '&' it breaks 400+ specs as this is called by infer_status
    # via callbacks
    return true if school&.la_funded_provision?
    return will_not_need_chromebooks? unless will_need_chromebooks?
    school_or_rb_domain.present? && recovery_email_address.present?
  end

  def chromebook_info_still_needed?
    will_need_chromebooks.nil? || will_need_chromebooks == 'i_dont_know'
  end

  def update_chromebook_information_and_status!(params)
    update!(params)
    refresh_status!
  end

  def invite_school_contact!
    if school_contact
      transaction do
        user = CreateUserService.invite_school_user(
          email_address: school_contact.email_address,
          full_name: school_contact.full_name,
          telephone: school_contact.phone_number,
          school_id: school_id,
          orders_devices: true,
        )
        update!(school_contacted_at: Time.zone.now, status: infer_status) if user.errors.blank?
      end
    end
  end

  private

  def any_school_users?
    school&.user_schools&.any?
  end

  def check_and_update_status_if_necessary
    if will_need_chromebooks_changed? || who_will_order_devices_changed?
      self.status = infer_status
    end
  end

  def set_defaults
    self.status ||= infer_status
  end
end
