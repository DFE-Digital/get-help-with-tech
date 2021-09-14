class ResponsibleBody::Devices::ChromebookInformationController < ResponsibleBody::BaseController
  before_action :find_school!

  def edit
    @chromebook_information_form = ChromebookInformationForm.new(
      school: @school,
      will_need_chromebooks: @school.will_need_chromebooks,
      school_or_rb_domain: @school.preorder_information&.school_or_rb_domain,
      recovery_email_address: @school.preorder_information&.recovery_email_address,
    )
    load_schools_by_order_status
  end

  def update
    authorize ChromebookInformationForm.new, policy_class: ResponsibleBody::BasePolicy

    @chromebook_information_form = ChromebookInformationForm.new(
      { school: @school }.merge(chromebook_params),
    )
    if @chromebook_information_form.valid?
      @school.update_chromebook_information_and_status!(chromebook_params)
      redirect_to responsible_body_devices_school_path(urn: @school.urn)
    else
      load_schools_by_order_status
      render :edit, status: :unprocessable_entity
    end
  end

private

  def find_school!
    @school = @responsible_body.schools.where_urn_or_ukprn_or_provision_urn(params[:school_urn]).first!
  end

  def chromebook_params
    params.require(:chromebook_information_form).permit(
      :will_need_chromebooks,
      :school_or_rb_domain,
      :recovery_email_address,
    )
  end

  def load_schools_by_order_status
    @schools = @responsible_body.schools_by_order_status
  end
end
