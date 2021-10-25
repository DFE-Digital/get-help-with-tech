class ResponsibleBody::Devices::SchoolsController < ResponsibleBody::BaseController
  before_action :load_schools_by_order_status, only: %i[show index]

  def index
    @show_devices_ordered_column = lacks_virtual_cap?
  end

  def show
    @school = @responsible_body.schools.where_urn_or_ukprn_or_provision_urn(params[:urn]).first!
    if @school.needs_contact?
      redirect_to responsible_body_devices_school_who_to_contact_path(@school.urn)
    elsif @school.orders_managed_centrally?
      @chromebook_information_form = ChromebookInformationForm.new(school: @school)
    end
  end

  def order_devices
    @school = @responsible_body.schools.where_urn_or_ukprn_or_provision_urn(params[:urn]).first!
  end

private

  def load_schools_by_order_status
    @schools = @responsible_body.schools_by_order_status
  end

  def lacks_virtual_cap?
    !@responsible_body.vcap_active?
  end
end
