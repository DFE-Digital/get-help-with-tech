class ImportContactsService
  attr_reader :datasource

  def initialize(school_datasource = GetInformationAboutSchools)
    @datasource = school_datasource
  end

  def import_contacts
    datasource.contacts do |contact_data|
      school = School.find_by(urn: contact_data[:urn])
      next unless school

      add_contact_to_school(school, contact_data)

      school.update!(phone_number: contact_data[:phone_number])

    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(e.message)
    end
  end

private

  def add_contact_to_school(school, contact_data)
    attrs = contact_attrs(contact_data)
    contact = school.contacts.find_by(email_address: contact_data[:email_address])

    if contact.nil?
      school.contacts.create!(attrs)
    else
      contact.update!(attrs)
    end
  end

  def contact_attrs(contact_data)
    contact_data.except(:urn).merge(role: 'headteacher')
  end
end
