class Computacenter::SchoolChangesDetailsComponent < ViewComponent::Base
  attr_accessor :school

  def initialize(school:)
    @school = school
  end

  def rows
    array = rb_rows.concat(school_rows)
    array.concat(ship_to_row) if school.computacenter_reference.present?
    array
  end

private

  def rb_rows
    [{
      key: 'RB URN',
      value: school.responsible_body.computacenter_identifier,
    },
     {
       key: 'Sold To',
       value: school.responsible_body.computacenter_reference,
     }]
  end

  def school_rows
    [{
      key: 'School URN',
      value: school.urn,
    },
     {
       key: 'School name',
       value: school.name,
     },
     {
       key: 'Address',
       value: school.address,
     }]
  end

  def ship_to_row
    [{
      key: 'Ship To',
      value: school.computacenter_reference,
    }]
  end
end
