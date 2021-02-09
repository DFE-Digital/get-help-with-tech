class Support::Gias::SchoolsToCloseController < Support::BaseController
  before_action { authorize :gias }
  before_action :get_staged_school, only: %i[show update]

  def index
    @closed_schools = closed_schools
  end

  def show; end

  def update
    school = @school.counterpart_school
    school.close!
    flash[:success] = "#{school.name} (#{school.urn}) has been closed"
    redirect_to support_gias_schools_to_close_index_path
  end

private

  def get_staged_school
    @school = DataStage::School.find_by(urn: params[:urn])
  end

  def closed_schools
    school_update_service.schools_that_need_to_be_closed.order(urn: :asc)
  end

  def school_update_service
    @school_update_service ||= SchoolUpdateService.new
  end
end
