class Support::Users::SchoolsController < Support::BaseController
  before_action :set_user
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
    @form = Support::SchoolSuggestionForm.new(user_school_params.merge(except: @user.schools))
    if @form.valid?
      @school_options = @form.matching_schools_options
    else
      render :search_again, status: :unprocessable_entity
    end
  end

  def create
    @form = Support::SchoolSuggestionForm.new(user_school_params.merge(except: @user.schools))

    if @form.invalid?
      render :search_again, status: :unprocessable_entity
    elsif @form.matching_schools.size == 1
      school = @form.matching_schools.first
      user_school = @user.user_schools.build(school_id: school.id)
      if user_school.save
        flash[:success] = "#{@user.full_name} is now associated with #{school.name}"
      else
        flash[:warning] = user_school.errors.full_messages.join("\n")
      end
      redirect_to support_user_path(@user)
    else
      redirect_to action: :new, support_school_suggestion_form: { name_or_urn_or_ukprn: user_school_params[:name_or_urn_or_ukprn] }
    end
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

  def user_school_params
    params.fetch('support_school_suggestion_form', {}).permit(:name_or_urn_or_ukprn, :school_urn)
  end

  def set_school
    @school = @user.schools.where_urn_or_ukprn_or_provision_urn(params[:urn]).first || School.gias_status_open.where_urn_or_ukprn_or_provision_urn(params[:urn]).first
  end

  def update_schools_params
    params.require(:user).require(:school_ids).reject(&:blank?)
  end
end
