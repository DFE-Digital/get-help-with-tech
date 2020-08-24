class ResponsibleBody::Devices::WhoToContactController < ResponsibleBody::Devices::BaseController
  before_action :find_school!

  def new
    @form = ResponsibleBody::Devices::WhoToContactForm.new(
      school: @school,
      headteacher_contact: @school.headteacher_contact,
    )
  end

  def create
    @form = ResponsibleBody::Devices::WhoToContactForm.new({
      school: @school,
      headteacher_contact: @school.headteacher_contact,
    }.merge(who_to_contact_form_params))

    if @form.invalid?
      render :new, status: :unprocessable_entity
    else
      chosen_contact = @form.chosen_contact
      chosen_contact.save! unless chosen_contact.persisted?
      @school.preorder_information.update!(school_contact: chosen_contact)
      flash[:success] = I18n.t(:success, scope: %i[responsible_body devices schools who_to_contact create], email_address: chosen_contact.email_address)
      redirect_to responsible_body_devices_school_path(@school.urn)
    end
  end

private

  def find_school!
    @school = @responsible_body.schools.find_by!(urn: params[:school_urn])
  end

  def who_to_contact_form_params
    params
      .require(:responsible_body_devices_who_to_contact_form)
      .permit(:who_to_contact, :full_name, :email_address, :phone_number)
  end
end
