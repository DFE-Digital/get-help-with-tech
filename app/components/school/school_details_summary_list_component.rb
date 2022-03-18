class School::SchoolDetailsSummaryListComponent < ViewComponent::Base
  validates :school, presence: true

  def initialize(school:)
    @school = school
  end

  def rows
    array = []
    array << device_allocation_row
    array << router_allocation_row if display_router_allocation_row?
    array << type_of_school_row
  end

private

  def device_allocation_row
    {
      key: 'Device allocation',
      value: pluralize(@school.raw_allocation(:laptop), 'device'),
    }
  end

  def router_allocation_row
    {
      key: 'Router allocation',
      value: @school.raw_allocation(:router).positive? ? 'routers are available to order' : 'no routers are available to order',
    }
  end

  def display_router_allocation_row?
    false
  end

  def type_of_school_row
    {
      key: 'Setting',
      value: @school.human_for_school_type,
    }
  end
end
