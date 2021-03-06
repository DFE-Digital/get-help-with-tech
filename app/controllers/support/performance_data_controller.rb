class Support::PerformanceDataController < ApplicationController
  before_action :authenticate_with_bearer_token

private

  def authenticate_with_bearer_token
    authenticate_or_request_with_http_token do |token, _options|
      token == access_token
    end
  end

  def access_token
    Settings.support.performance_data_access_token
  end
end
