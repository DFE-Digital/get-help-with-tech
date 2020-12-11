class Support::BaseController < ApplicationController
  before_action :require_sign_in!
  after_action :verify_authorized
  after_action :verify_policy_scoped, if: :index_method?

private

  def index_method?
    %i[index results].include?(action_name)
  end
end
