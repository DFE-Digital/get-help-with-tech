class ResponsibleBodiesController < ApplicationController
  before_action :require_sign_in!
  before_action :build_reponsible_body

  def show; end

private

  def build_reponsible_body
    # @responsible_body = ResponsibleBody.find(@user.responsible_body_id)
  end
end
