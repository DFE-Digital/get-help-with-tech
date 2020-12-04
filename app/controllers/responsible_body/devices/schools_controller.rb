class ResponsibleBody::Devices::SchoolsController < ResponsibleBody::BaseController
  def index
    schools = @responsible_body.schools
      .includes(:preorder_information)
      .includes(:std_device_allocation)
      .gias_status_open
      .order(name: :asc)

    @ordering_schools = schools.can_order
    @specific_circumstances_schools = schools.can_order_for_specific_circumstances
    @fully_open_schools = schools.where(order_state: %w[cannot_order cannot_order_as_reopened])
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
