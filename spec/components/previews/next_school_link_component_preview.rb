class NextSchoolLinkComponentPreview < ViewComponent::Preview
  def with_next_school
    school = School.all.sample
    render(ResponsibleBody::NextSchoolLinkComponent.new(current_school: school, recordsets: [School.all]))
  end
end
