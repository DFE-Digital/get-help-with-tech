class ChangeSchoolHeadteacherService
  attr_reader :school, :details

  def initialize(school, **details)
    @school = school
    @details = details
  end

  def call
    attributes = details.except(:id).merge!(role: :headteacher)
    headteacher_id = details[:id] if valid_id?
    SchoolContact.find_or_initialize_by(school_id: school.id, id: headteacher_id).tap do |headteacher|
      headteacher.update(attributes)
    end
  end

private

  def valid_id?
    school.contacts.exists?(id: details[:id])
  end
end
