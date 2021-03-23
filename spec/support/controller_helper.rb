module ControllerHelper
  def create_session_id!
    # TestSession doesn't do this automatically like a real session
    session[:session_id] = SecureRandom.uuid
  end

  def sign_in_as(user)
    session.clear
    create_session_id!
    controller.send(:save_user_to_session!, user)
  end

  def impersonate(user)
    session[:impersonated_user_id] = user.id
  end
end

RSpec.configure do |c|
  c.include ControllerHelper, type: :controller
end

RSpec::Matchers.define :be_forbidden_for do |user|
  match do |actual|
    sign_in_as user

    actual.call

    response.status == 403
  end

  supports_block_expectations
end

RSpec::Matchers.define :receive_status_ok_for do |user|
  match do |actual|
    sign_in_as user

    actual.call

    response.status == 200
  end

  supports_block_expectations
end
