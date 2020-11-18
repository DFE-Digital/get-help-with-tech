class Support::ResponsibleBodiesController < Support::BaseController
  before_action { authorize ResponsibleBody }

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
    @users = policy_scope(@responsible_body.users).not_deleted.order('last_signed_in_at desc nulls last, updated_at desc')
    @schools = @responsible_body
      .schools
      .includes(:device_allocations, :preorder_information)
      .order(name: :asc)
  end
end
