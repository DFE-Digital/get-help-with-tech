class SchoolsController < ApplicationController
  before_action :require_sign_in!

  def index
    @schools = @user.schools
    if @user.schools.size == 1 && \
        (@user.is_a_single_academy_trust_user? || !@user.is_responsible_body_user?)
      redirect_to home_school_path(@user.schools.first)
    end
  end
end
