class Support::ResponsibleBodiesController < Support::BaseController
  def index
    @responsible_bodies = ResponsibleBody
      .select('responsible_bodies.*')
      .excluding_department_for_education
      .with_users_who_have_signed_in_at_least_once(privacy_notice_required: @current_user.is_computacenter?)
      .with_user_count(privacy_notice_required: @current_user.is_computacenter?)
      .with_completed_preorder_info_count
      .order('type asc, name asc')
  end

  def show
    @responsible_body = ResponsibleBody.find(params[:id])
    @users = @responsible_body.users.safe_to_show_to(@current_user).not_deleted.order('last_signed_in_at desc nulls last, updated_at desc')
    @schools = @responsible_body
      .schools
      .includes(:device_allocations, :preorder_information)
      .gias_status_open
      .order(name: :asc)
  end
end
