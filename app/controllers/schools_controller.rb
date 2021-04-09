class SchoolsController < ApplicationController
  before_action :require_sign_in!

  def index
    @schools = impersonated_or_current_user.schools

    if impersonated_or_current_user.schools.one? && \
        (impersonated_or_current_user.is_a_single_school_user? || !impersonated_or_current_user.is_responsible_body_user?)
      redirect_to home_school_path(impersonated_or_current_user.schools.first)
    end
  end
end
