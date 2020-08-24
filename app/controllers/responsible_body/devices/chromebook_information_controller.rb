class ResponsibleBody::Devices::ChromebookInformationController < ResponsibleBody::Devices::BaseController
  before_action :find_school!

  def edit
    @chromebook_information_form = ResponsibleBody::Devices::ChromebookInformationForm.new(
      school: @school,
      will_need_chromebooks: @school.preorder_information&.will_need_chromebooks,
      school_or_rb_domain: @school.preorder_information&.school_or_rb_domain,
      recovery_email_address: @school.preorder_information&.recovery_email_address,
    )
  end

  def update
    @preorder_info = @school.preorder_information
    @chromebook_information_form = ResponsibleBody::Devices::ChromebookInformationForm.new(
      { school: @school }.merge(chromebook_params),
    )
    if @chromebook_information_form.valid?
      @preorder_info.update!(chromebook_params.merge(status: @preorder_info.infer_status))
      redirect_to responsible_body_devices_school_path(urn: @school.urn)
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def find_school!
    @school = @responsible_body.schools.find_by!(urn: params[:school_urn])
  end

  def chromebook_params
    params.require(:responsible_body_devices_chromebook_information_form).permit(
      :will_need_chromebooks,
      :school_or_rb_domain,
      :recovery_email_address,
    )
  end
end
