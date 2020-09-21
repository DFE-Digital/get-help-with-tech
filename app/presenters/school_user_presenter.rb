class SchoolUserPresenter < SimpleDelegator
  def orders_devices
    school_user.orders_devices? ? '1' : '0'
  end

private

  def school_user
    __getobj__
  end
end
