class Support::GiasInfoForm
  include ActiveModel::Model

  def new_schools
    school_update_service.schools_that_need_to_be_added.order(urn: :asc)
  end

  def new_schools_count
    school_update_service.schools_that_need_to_be_added.count
  end

  def closed_schools
    school_update_service.schools_that_need_to_be_closed.order(urn: :asc)
  end

  def closed_schools_count
    school_update_service.schools_that_need_to_be_closed.count
  end

  def new_trusts; end

  def closed_trusts; end

private

  def school_update_service
    @school_update_service ||= SchoolUpdateService.new
  end
end
