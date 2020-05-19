class ApplicationFormsController < ApplicationController
  def new
    @application_form = ApplicationForm.new(user: @user)
  end
end
