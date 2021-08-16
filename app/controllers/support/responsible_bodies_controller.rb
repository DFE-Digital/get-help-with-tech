class Support::ResponsibleBodiesController < Support::BaseController
  before_action { authorize ResponsibleBody }

  def index
    @responsible_bodies = policy_scope(ResponsibleBody)
      .select('responsible_bodies.*')
      .excluding_department_for_education
      .with_users_who_have_signed_in_at_least_once(privacy_notice_required: @current_user.is_computacenter?)
      .with_user_count(privacy_notice_required: @current_user.is_computacenter?)
      .with_completed_preorder_info_count
      .order('type asc, name asc')
  end

  def show
    @responsible_body = ResponsibleBody.find(params[:id])
    @virtual_cap_pools = @responsible_body.virtual_cap_pools.with_std_device_first
    @users = policy_scope(@responsible_body.users).order('last_signed_in_at desc nulls last, updated_at desc')
    @schools = @responsible_body
      .schools
      .gias_status_open
      .includes(:device_allocations, :preorder_information)
      .order(name: :asc)
    @closed_schools = @responsible_body
      .schools
      .gias_status_closed
      .includes(:device_allocations, :preorder_information)
      .left_outer_joins(:user_schools)
      .select('schools.*, count(user_schools.id) AS user_count')
      .group('schools.id')
      .order(name: :asc)
  end
end
