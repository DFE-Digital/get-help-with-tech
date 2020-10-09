class SchoolsController < ApplicationController
  before_action :require_sign_in!

  def index
    @schools = @user.schools
    redirect_to home_school_path(@user.schools.first) if @user.schools.size == 1
  end
end
