class ImportContactsService
  attr_reader :datasource

  def initialize(school_datasource)
    @datasource = school_datasource
  end

  def import_contacts
    datasource.records do |contact_data|
      school = School.find_by(urn: contact_data[:urn])
      next unless school

      attrs = user_attrs(contact_data)

      next if attrs[:email_address].blank? || attrs[:full_name].blank?

      set_contact_data(school, attrs)

    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(e.message)
    end
  end

private

  def set_contact_data(school, attrs)
    if attrs[:email_address] && attrs[:full_name]
      user = create_or_update_user!(attrs[:email_address],
                                    attrs[:full_name])

      create_or_update_role!(school, user, attrs[:title])
    end

    school.update!(phone_number: attrs[:phone_number])
  end

  def create_or_update_user!(email_address, full_name)
    user = User.find_by(email_address: email_address)

    if user.nil?
      User.create!(email_address: email_address,
                   full_name: full_name)
    else
      user.update!(full_name: full_name)
      user
    end
  end

  def create_or_update_role!(school, user, title)
    role = school.roles.headteacher.first

    if role.nil?
      school.roles.create!(user: user,
                           title: title,
                           role: 'headteacher')
    else
      role.update!(user_id: user.id,
                   title: title)
      role
    end
  end

  def user_attrs(contact_data)
    {
      email_address: contact_data[:email_address],
      full_name: contact_data[:full_name],
      title: contact_data[:title],
      phone_number: contact_data[:phone_number],
    }
  end
end
