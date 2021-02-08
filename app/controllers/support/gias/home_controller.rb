class Support::Gias::HomeController < Support::BaseController
  before_action { authorize :gias }

  def index
    @new_schools_count = new_schools_count
    @closed_schools_count = closed_schools_count
  end

private

  def new_schools_count
    school_update_service.schools_that_need_to_be_added.count
  end

  def closed_schools_count
    school_update_service.schools_that_need_to_be_closed.count
  end

  def school_update_service
    @school_update_service ||= SchoolUpdateService.new
  end
end
