class AllocationRequestFormsController < ApplicationController
  def new
    @allocation_request_form = AllocationRequestForm.new(user: @user)
  end
end
