class ResponsibleBody::Devices::SchoolsController < ResponsibleBody::Devices::BaseController
  def index
    @schools = @responsible_body.schools
                                .includes(:preorder_information)
                                .includes(:std_device_allocation)
                                .order(name: :asc)
  end

  def show
    @school = @responsible_body.schools.find_by!(urn: params[:urn])
  end
end
