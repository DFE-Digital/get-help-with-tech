class Support::School::ChangeHeadteacherForm
  include ActiveModel::Model

  attr_accessor :email_address, :full_name, :id, :phone_number, :role, :school, :title

  def headteacher?
    role == 'headteacher'
  end

  def save
    updated_headteacher.errors.empty? || save_error
  end

private

  def updated_headteacher
    @headteacher ||= ChangeSchoolHeadteacherService.new(school, **headteacher_details).call
  end

  def headteacher_details
    {
      email_address:,
      full_name:,
      id: id.presence,
      phone_number: phone_number.presence,
      title: title.presence,
    }.compact
  end

  def save_error
    errors.copy!(updated_headteacher.errors)
    false
  end
end
