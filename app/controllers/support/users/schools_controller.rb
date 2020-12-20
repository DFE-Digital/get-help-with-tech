class Support::Users::SchoolsController < Support::BaseController
  before_action :set_user, :set_school
  before_action { authorize User }

  def index
    @schools = @user.schools.order(:name)
    @responsible_body = @user.responsible_body
    @user_responsible_body_form = Support::UserResponsibleBodyForm.new(
      user: @user,
      possible_responsible_bodies: ResponsibleBody.gias_status_open.order(type: :asc, name: :asc),
    )
    @user_school_form = Support::SchoolSuggestionForm.new
  end

  def new
    @form = Support::SchoolSuggestionForm.new(user_school_params)
    @schools = @form.matching_schools
  end

  def create
    @user_school = @user.user_schools.build(school_id: @school.id)
    if @user_school.save
      flash[:success] = "#{@user.full_name} is now associated with #{@school.name}"
    else
      flash[:warning] = @user_school.errors.full_messages.join("\n")
    end
    redirect_to support_user_path(@user)
  end

  def update_schools
    @user.schools = @user.schools.where(id: update_schools_params)
    flash[:success] = 'Schools updated'
    redirect_to support_user_path(@user)
  end

private

  def set_user
    @user = User.find(params[:user_id])
    authorize @user, :edit?
  end

  def set_school
    @school = @user.schools.find_by(urn: params[:urn]) || School.gias_status_open.find_by(urn: params[:urn])
  end

  def user_school_params(opts = params)
    opts.fetch('support_school_suggestion_form').permit(:name_or_urn, :school_urn)
  end

  def update_schools_params
    params.require(:user).require(:school_ids).reject(&:blank?)
  end
end
