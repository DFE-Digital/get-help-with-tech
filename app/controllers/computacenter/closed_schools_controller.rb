class Computacenter::ClosedSchoolsController < Computacenter::BaseController
  def index
    query = School.gias_status_open
    @total_count = query.that_can_order_now.count
    @specific_circumstances_count = query.can_order_for_specific_circumstances.count
    @closed_count = query.can_order.count

    @pagination, @schools = pagy(fetch_schools_for_view)
  end

private

  def fetch_schools_for_view
    School.joins(:responsible_body)
      .includes(:std_device_allocation, :coms_device_allocation)
      .gias_status_open
      .send(query_for_view_mode)
      .order(ResponsibleBody.arel_table[:type].asc, ResponsibleBody.arel_table[:name].asc, School.arel_table[:name].asc)
  end

  def view_mode
    @view_mode ||= parse_view_mode
  end

  def parse_view_mode
    mode = params[:view]
    mode = 'all' unless mode.in? %w[partially-closed fully-closed]
    mode
  end

  def query_for_view_mode
    case view_mode
    when 'partially-closed'
      :can_order_for_specific_circumstances
    when 'fully-closed'
      :can_order
    else
      :that_can_order_now
    end
  end
end
