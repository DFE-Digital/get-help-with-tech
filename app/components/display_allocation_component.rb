class DisplayAllocationComponent < ViewComponent::Base
  attr_reader :school

  def initialize(school:)
    @school = school
  end

  def allocation
    [
      build_text(school.allocation(:laptop), 'device'),
      build_text(school.allocation(:router), 'router'),
    ]
  end

private

  def build_text(count, name)
    "#{count}&nbsp;#{name.pluralize(count)}"
  end
end
