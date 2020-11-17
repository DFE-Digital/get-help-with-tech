class SchoolsController < ApplicationController
  before_action :require_sign_in!

  def index
    @schools = @current_user.schools
    if @current_user.schools.size == 1 && \
        (@current_user.is_a_single_academy_trust_user? || !@current_user.is_responsible_body_user?)
      redirect_to home_school_path(@current_user.schools.first)
    end
  end
end
