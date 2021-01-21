class SupportTicket
  def initialize(params:)
    @params = ActiveSupport::HashWithIndifferentAccess.new(params)
  end

  def user_type
    @params.fetch(:user_type, 'other_type_of_user')
  end

  def school_name
    @params.fetch(:school_name, '')
  end

  def school_unique_id
    @params.fetch(:school_unique_id, '')
  end

  def full_name
    @params.fetch(:full_name, '')
  end

  def email_address
    @params.fetch(:email_address, '')
  end

  def telephone_number
    @params.fetch(:telephone_number, '')
  end

  def support_topics
    @params.fetch(:support_topics, [])
  end

  def message
    @params.fetch(:message, '')
  end

  def requires_school?
    %w[parent_or_guardian_or_carer_or_pupil_or_care_leaver other_type_of_user].exclude? user_type
  end
end
