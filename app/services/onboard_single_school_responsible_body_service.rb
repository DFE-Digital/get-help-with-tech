class OnboardSingleSchoolResponsibleBodyService
  def initialize(urn:)
    @urn = urn
  end

  def call
    return unless single_school_responsible_body?

    responsible_body.update!(in_devices_pilot: true)
    devolve_ordering_to_the_school

    ensure_both_responsible_body_and_school_have_users
  end

private

  def ensure_both_responsible_body_and_school_have_users
    if responsible_body.users.present?
      add_responsible_body_users_to_school
      mark_school_as_invited
    elsif school_has_headteacher_contact?
      invite_school_headteacher
      add_school_headteacher_to_responsible_body
    else
      raise 'Cannot continue without RB users or a school headteacher'
    end
  end

  def add_responsible_body_users_to_school
    first_rb_user = responsible_body.users.first
    set_user_as_school_contact(first_rb_user)
    make_school_user(first_rb_user)

    (responsible_body.users - [first_rb_user]).each do |user|
      make_school_user(user)
    end
  end

  def set_user_as_school_contact(user_to_contact)
    contact = school.contacts.create!(email_address: user_to_contact.email_address,
                                      full_name: user_to_contact.full_name,
                                      role: :contact,
                                      phone_number: user_to_contact.telephone)
    school.preorder_information.update!(school_contact: contact)
  end

  def mark_school_as_invited
    PreorderInformation.transaction do
      school.preorder_information.update!(school_contacted_at: Time.zone.now)
      school.preorder_information.update!(status: school.preorder_information.infer_status)
    end
  end

  def make_school_user(user)
    # we can't have more than 3 school users who order devices!
    user.update!(orders_devices: false) if school.users.count >= 3
    school.users << user
    InviteSchoolUserMailer.with(user: user).nominated_contact_email.deliver_later
  end

  def add_school_headteacher_to_responsible_body
    headteacher_user = school.users.find_by!(email_address: school.headteacher_contact.email_address)
    headteacher_user.update!(responsible_body: responsible_body)
  end

  def school_has_headteacher_contact?
    school.headteacher_contact.present?
  end

  def invite_school_headteacher
    choose_headteacher_as_school_contact
    school.invite_school_contact
  end

  def choose_headteacher_as_school_contact
    school.preorder_information.update!(school_contact: school.headteacher_contact)
  end

  def devolve_ordering_to_the_school
    responsible_body.update_who_will_order_devices('schools')
  end

  def single_school_responsible_body?
    responsible_body&.schools&.size == 1
  end

  def school
    @school ||= School.find_by!(urn: @urn)
  end

  def responsible_body
    school.responsible_body
  end
end
