module HuaweiRouterPasswordsHelper
  def last_breadcrumb_path_for_huawei
    if current_user.is_responsible_body_user?
      responsible_body_internet_path
    elsif current_user.is_school_user?
      internet_school_path(current_user.school)
    else
      safe_path_for_other_user_types
    end
  end

  def safe_path_for_other_user_types
    root_path
  end
end
