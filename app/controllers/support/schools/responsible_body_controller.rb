class Support::Schools::ResponsibleBodyController < Support::BaseController
  before_action :set_school
  before_action :redirect_if_same_responsible_body, only: %i[update]

  attr_reader :school

  def edit
    @responsible_body = @school.responsible_body
    @form = Support::School::ChangeResponsibleBodyForm.new(school: school)
  end

  def update
    if Support::School::ChangeResponsibleBodyForm.new(school: school, responsible_body_id: new_responsible_body_id).save
      flash[:success] = success_message
    else
      flash[:warning] = error_message
    end

    redirect_to support_school_path(school)
  end

private

  def error_message
    "#{school.name} could not be associated with #{school.responsible_body_name}!"
  end

  def no_change_message
    "Responsible body not changed for #{school.name}"
  end

  def new_responsible_body_id
    responsible_body_params[:responsible_body_id]
  end

  def same_responsible_body?
    new_responsible_body_id.to_s == school.responsible_body_id.to_s
  end

  def success_message
    "#{school.name} is now associated with #{school.responsible_body_name}"
  end

  # Filters
  def redirect_if_same_responsible_body
    if same_responsible_body?
      flash[:info] = no_change_message
      redirect_to support_school_path(school)
    end
  end

  def set_school
    @school = School.gias_status_open.where_urn_or_ukprn_or_provision_urn(params[:school_urn]).first
    authorize school, :update_responsible_body?
  end

  # Params
  def responsible_body_params
    params.require(:support_school_change_responsible_body_form).permit(:responsible_body_id)
  end
end
