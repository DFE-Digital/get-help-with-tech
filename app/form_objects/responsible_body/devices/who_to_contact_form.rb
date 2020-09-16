class ResponsibleBody::Devices::WhoToContactForm
  include ActiveModel::Model

  attr_accessor :school, :who_to_contact, :headteacher_contact, :full_name, :email_address, :phone_number

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

  def headteacher_option_label
    @headteacher_contact.title.upcase_first
  end

  def headteacher_option_hint_text
    "#{@headteacher_contact.full_name} (#{@headteacher_contact.email_address})"
  end

  def chosen_contact
    if headteacher_chosen?
      headteacher_contact
    elsif someone_else_chosen?
      school.contacts.find_or_initialize_by(email_address: email_address).tap do |contact|
        contact.role = :contact
        contact.full_name = full_name
        contact.phone_number = phone_number
      end
    end
  end

private

  def headteacher_chosen?
    who_to_contact&.to_sym == :headteacher
  end

  def someone_else_chosen?
    who_to_contact&.to_sym == :someone_else
  end
end
