class ResponsibleBody::Devices::SchoolsController < ResponsibleBody::BaseController
  before_action :load_schools_by_order_status, only: %i[show index]

  def index
    @vcap = @responsible_body.vcap?
  end

  def show
    @school = @responsible_body.schools.where_urn_or_ukprn_or_provision_urn(params[:urn]).first!
    if @school.needs_contact?
      redirect_to responsible_body_devices_school_who_to_contact_path(@school.urn)
    elsif @school.orders_managed_centrally?
      @chromebook_information_form = ChromebookInformationForm.new(school: @school)
    end
  end

private

  def load_schools_by_order_status
    @schools = @responsible_body.schools_by_order_status
  end
end
