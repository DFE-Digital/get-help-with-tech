class ResponsibleBody::Internet::HuaweiRouterPasswordsController < ResponsibleBody::BaseController
  def new
    @password = Settings.huawei.devices.password
  end
end
