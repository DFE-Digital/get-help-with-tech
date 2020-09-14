class UserOrganisationsController < ApplicationController
  before_action :require_sign_in!

  def index
    @form = SignInAsUserOrganisationForm.new(user: @user)
  end
end
