class HuaweiRouterPasswordsController < ApplicationController
  before_action :require_sign_in!

  def new
    @password = Settings.huawei.devices.password
    @breadcrumb_path = if current_user.is_responsible_body_user?
                         responsible_body_internet_path
                       elsif current_user.is_school_user?
                         internet_school_path(current_user.school)
                       else
                         safe_path_for_other_user_types
                       end
  end

private

  def safe_path_for_other_user_types
    root_path
  end
end
