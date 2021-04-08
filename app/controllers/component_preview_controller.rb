class ComponentPreviewController < ViewComponentsController
  layout 'application'

  def hide_nav_menu?
    false
  end

  def impersonated_user
    nil
  end
  helper_method :impersonated_user
end
