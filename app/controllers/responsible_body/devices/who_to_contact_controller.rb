class ResponsibleBody::Devices::WhoToContactController < ResponsibleBody::BaseController
  before_action :find_school!

  def new
    load_schools_by_order_status
    @form = ResponsibleBody::Devices::WhoToContactForm.new(school: @school)
  end

  def create
    authorize ResponsibleBody::Devices::WhoToContactForm, policy_class: ResponsibleBody::BasePolicy

    create_or_update
  end

  def edit
    @form = ResponsibleBody::Devices::WhoToContactForm.new(school: @school)
    @form.populate_details_from_second_contact
    @form.preselect_who_to_contact
  end

  def update
    authorize ResponsibleBody::Devices::WhoToContactForm, policy_class: ResponsibleBody::BasePolicy

    create_or_update
  end

private

  def create_or_update
    @form = ResponsibleBody::Devices::WhoToContactForm.new({
      school: @school,
    }.merge(who_to_contact_form_params))

    if @form.invalid?
      render :new, status: :unprocessable_entity
    else
      chosen_contact = @form.chosen_contact
      chosen_contact.save!
      @school.set_school_contact!(chosen_contact)
      is_success = @school.invite_school_contact
      flash[:success] = I18n.t(
        is_success ? :success : :failure,
        scope: %i[responsible_body devices schools who_to_contact create],
        email_address: chosen_contact.email_address,
      )
      redirect_to responsible_body_devices_school_path(@school.urn)
    end
  end

  def find_school!
    @school = @responsible_body.schools.where_urn_or_ukprn_or_provision_urn(params[:school_urn]).first!
  end

  def who_to_contact_form_params
    params
      .require(:responsible_body_devices_who_to_contact_form)
      .permit(:who_to_contact, :full_name, :email_address, :phone_number)
  end

  def load_schools_by_order_status
    @schools = @responsible_body.schools_by_order_status
  end
end
