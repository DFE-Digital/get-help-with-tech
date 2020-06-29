module ControllerHelper
  def sign_in_as(user)
    # TestSession doesn't do this automatically like a real session
    session[:session_id] = SecureRandom.uuid
    controller.send(:save_user_to_session!, user)
  end
end
