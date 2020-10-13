class ResponsibleBody::Devices::SchoolsController < ResponsibleBody::Devices::BaseController
  def index
    @schools = @responsible_body.schools
                                .includes(:preorder_information)
                                .includes(:std_device_allocation)
                                .order(name: :asc)
  end

  def show
    @school = @responsible_body.schools.find_by!(urn: params[:urn])
    if @school.preorder_information.needs_contact?
      redirect_to responsible_body_devices_school_who_to_contact_path(@school.urn)
    elsif @school.preorder_information.orders_managed_centrally?
      @chromebook_information_form = ChromebookInformationForm.new(school: @school)
    end
  end

  def order_devices
    @school = @responsible_body.schools.find_by!(urn: params[:urn])
  end
end
