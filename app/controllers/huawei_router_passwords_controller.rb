class HuaweiRouterPasswordsController < ApplicationController
  before_action :require_sign_in!

  def new
    @password = Settings.huawei.devices.password
  end
end
