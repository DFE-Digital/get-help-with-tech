class School::DetailsPolicy < School::BasePolicy
  def show?
    !record.la_funded_provision?
  end
end
