class ResponsibleBody::NextSchoolLinkComponent < ViewComponent::Base
  attr_accessor :current_school, :recordsets

  def initialize(current_school:, recordsets:)
    @current_school = current_school
    @recordsets = recordsets
  end

  def next_school
    next_school_in_recordset(recordset_containing_school)
  end

private

  def recordset_containing_school(school = @current_school)
    @recordsets.find do |recordset|
      recordset.pluck(:id).include?(school.id)
    end
  end

  def next_school_in_recordset(recordset, school = @current_school)
    if (index_of_school = recordset.pluck(:id).index(school.id))
      recordset[index_of_school + 1]
    end
  end
end
