class Support::Users::SchoolsController < Support::BaseController
  before_action :set_user, :set_school
  before_action { authorize User }

  def new
    @form = Support::NewUserSchoolForm.new(user: @user, name_or_urn: user_school_params[:name_or_urn])
    @schools = @form.matching_schools
  end

  def create
    @user_school = @user.user_schools.build(school_id: @school.id)
    if @user_school.save
      flash[:success] = "#{@user.full_name} is now associated with #{@school.name}"
    else
      flash[:warning] = @user_school.errors.full_messages.join("\n")
    end
    redirect_to associated_organisations_support_user_path(@user.id)
  end

  def destroy
    @user.schools.destroy(@school)
    flash[:success] = "#{@user.full_name} is no longer associated with #{@school.name}"
    redirect_to associated_organisations_support_user_path(@user.id)
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
    opts.fetch('support_new_user_school_form').permit(:name_or_urn)
  end
end
