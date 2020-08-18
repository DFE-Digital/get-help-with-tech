class ResponsibleBody::Devices::SchoolsController < ResponsibleBody::Devices::BaseController
  def index
    @schools = @responsible_body.schools.order(name: :asc)
  end
end
