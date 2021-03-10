class School::DevicesController < School::BaseController
  def order
    if @school.can_order_devices_right_now?
      if @current_user.has_an_active_techsource_account? && @school.can_order_for_specific_circumstances?
        render :can_order_for_specific_circumstances
      elsif @current_user.has_an_active_techsource_account? && @school.can_order?
        render :can_order
      elsif @current_user.awaiting_techsource_account?
        render :can_order_awaiting_techsource
      else # user has no techsource account
        render :school_can_order_user_cannot
      end
    elsif @school.all_devices_ordered?
      render :cannot_order_as_cap_reached
    else
      render :cannot_order
    end
  end
end
