module ControllerHelper
  def create_session_id!
    # TestSession doesn't do this automatically like a real session
    session[:session_id] = SecureRandom.uuid
  end

  def sign_in_as(user)
    create_session_id!
    controller.send(:save_user_to_session!, user)
  end
end

RSpec.configure do |c|
  c.include ControllerHelper, type: :controller
end
