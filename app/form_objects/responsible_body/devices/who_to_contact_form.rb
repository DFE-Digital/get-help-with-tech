class ResponsibleBody::Devices::WhoToContactForm
  include ActiveModel::Model

  ROLE_WHO_TO_CONTACT = {
    headteacher: 'headteacher',
    contact: 'someone_else',
  }.freeze

  attr_accessor :school,
                :who_to_contact,
                :full_name,
                :email_address,
                :phone_number

  validates :who_to_contact, inclusion: %w[headteacher someone_else]

  validates :full_name,
            presence: true,
            length: { minimum: 2, maximum: 1024 },
            if: :someone_else_chosen?

  validates :email_address,
            presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            length: { minimum: 2, maximum: 1024 },
            if: :someone_else_chosen?

  validates :phone_number,
            presence: true,
            length: { minimum: 2, maximum: 30 },
            if: :someone_else_chosen?

  delegate :headteacher, to: :school

  def chosen_contact
    if headteacher_chosen?
      headteacher
    elsif someone_else_chosen?
      contact = school.contacts.find_by(email_address: email_address)
      contact ||= school.contacts.contact.first
      contact ||= school.contacts.build(role: :contact)

      contact.tap do |user|
        user.email_address = email_address
        user.full_name = full_name
        user.phone_number = phone_number
      end
    end
  end

  def headteacher_option_label
    school.headteacher_title.upcase_first
  end

  def headteacher_option_hint_text
    "#{school.headteacher_full_name} (#{school.headteacher_email_address})"
  end

  def populate_details_from_second_contact
    self.full_name = second_contact.full_name
    self.email_address = second_contact.email_address
    self.phone_number = second_contact.phone_number
  end

  def preselect_who_to_contact
    who = ROLE_WHO_TO_CONTACT[school_contact&.role]
    self.who_to_contact = who if who
  end

private

  def school_contact
    school.school_contact || SchoolContact.new
  end

  def second_contact
    school.contacts.contact.first || SchoolContact.new
  end

  def headteacher_chosen?
    who_to_contact&.to_sym == :headteacher
  end

  def someone_else_chosen?
    who_to_contact&.to_sym == :someone_else
  end
end
