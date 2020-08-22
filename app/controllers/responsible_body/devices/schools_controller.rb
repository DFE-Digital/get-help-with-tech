class ResponsibleBody::Devices::SchoolsController < ResponsibleBody::Devices::BaseController
  def index
    @schools = @responsible_body.schools
                                .includes(:preorder_information)
                                .order(name: :asc)
  end
end
