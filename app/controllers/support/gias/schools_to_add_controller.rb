class Support::Gias::SchoolsToAddController < Support::BaseController
  before_action { authorize :support }
  before_action :get_staged_school, only: [:show, :update]

  def index
    @gias_info_form = Support::GiasInfoForm.new
  end

  def show
  end

  def update
    begin
      new_school = school_update_service.create_school!(@school)
      flash[:success] = "#{new_school.name} (#{new_school.urn}) added"
      redirect_to support_gias_schools_to_add_index_path
    rescue DataStage::Error => e
      @school.errors.add(:base, e.message)
      render :show
    end
  end

private

  def get_staged_school
    @school = DataStage::School.find_by(urn: params[:urn])
  end

  def school_update_service
    @school_update_service ||= SchoolUpdateService.new
  end
end
