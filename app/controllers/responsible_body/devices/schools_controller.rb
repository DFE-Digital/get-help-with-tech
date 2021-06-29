class ResponsibleBody::Devices::SchoolsController < ResponsibleBody::BaseController
  before_action :load_schools_by_order_status, only: %i[show index]

  def index
    @show_devices_ordered_column = @responsible_body.virtual_cap_pools.none? || @responsible_body.has_virtual_cap_feature_flags?
  end

  def show
    @school = @responsible_body.schools.where_urn_or_ukprn_or_provision_urn(params[:urn]).first!
    if @school.preorder_information.needs_contact?
      redirect_to responsible_body_devices_school_who_to_contact_path(@school.urn)
    elsif @school.preorder_information.orders_managed_centrally?
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
end
