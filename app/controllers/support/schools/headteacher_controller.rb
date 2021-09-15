class Support::Schools::HeadteacherController < Support::BaseController
  before_action :set_school

  attr_reader :form, :school

  def edit
    @form = Support::School::ChangeHeadteacherForm.new(school: school, **contact_details)
  end

  def update
    @form = Support::School::ChangeHeadteacherForm.new(school: school, **headteacher_params)
    if form.save
      flash[:success] = success_message
      redirect_to support_school_path(school)
    else
      render(:edit)
    end
  end

private

  def contact_details
    contact = school.headteacher || school.contacts.first
    {
      email_address: contact&.email_address,
      full_name: contact&.full_name,
      id: contact&.id,
      phone_number: contact&.phone_number,
      role: contact&.role,
      title: contact&.title,
    }
  end

  def success_message
    "#{school.name}'s headteacher details updated"
  end

  # Filters
  def set_school
    @school = School.gias_status_open.where_urn_or_ukprn_or_provision_urn(params[:school_urn]).first
    authorize school, :update_headteacher?
  end

  # Params
  def headteacher_params
    @headteacher_params ||= params.require(:support_school_change_headteacher_form).permit(
      :email_address,
      :full_name,
      :id,
      :phone_number,
      :title,
    ).to_h
  end
end
