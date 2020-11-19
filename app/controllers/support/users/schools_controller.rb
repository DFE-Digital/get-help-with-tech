class Support::Users::SchoolsController < Support::BaseController
  before_action :set_user, :set_school

  def index
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
    @user_school = @user.user_schools.find_by_school_id(@school.id)
    @user_school&.destroy!
    flash[:success] = "#{@user.full_name} is no longer associated with #{@school.name}"
    redirect_to associated_organisations_support_user_path(@user.id)
  end

private

  def set_user
    # @user = User.safe_to_show_to(@current_user).find(params[:id])
    @user = User.find(params[:id])
  end

  def set_school
    @school = School.find_by_urn(params[:urn])
  end

  def user_school_params(opts = params)
    opts.fetch('support_new_user_school_form').permit(:name_or_urn)
  end
end
