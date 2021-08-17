class Support::Gias::SchoolsToAddController < Support::BaseController
  before_action { authorize :gias }
  before_action :get_staged_school, only: %i[show update]

  def index
    @new_schools = new_schools
  end

  def show; end

  def update
    new_school = school_update_service.create_school!(@school)
    flash[:success] = "#{new_school.name} (#{new_school.urn}) added"
    redirect_to support_gias_schools_to_add_index_path
  rescue DataStage::Error => e
    @school.errors.add(:base, e.message)
    render :show
  end

private

  def get_staged_school
    @school = new_schools.find_by(urn: params[:urn])
  end

  def new_schools
    school_update_service.schools_that_need_to_be_added.order(urn: :asc)
  end

  def school_update_service
    @school_update_service ||= SchoolUpdateService.new
  end
end
