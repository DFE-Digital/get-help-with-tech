class School::Internet::HuaweiRouterPasswordsController < School::BaseController
  def new
    @password = Settings.huawei.devices.password
  end
end
