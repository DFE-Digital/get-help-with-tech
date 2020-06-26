class MonitoringController < ApplicationController
  def healthcheck
    @healthcheck = HealthcheckService.run
    @status = (@healthcheck[:status] == 'UP' ? :ok : :internal_server_error)
    respond_to do |format|
      format.json do
        render json: @healthcheck.to_json, status: @status
      end
    end
  end
end
