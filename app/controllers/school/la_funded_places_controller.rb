class School::LaFundedPlacesController < School::BaseController
  def show; end

  def order
    if @school.will_need_chromebooks.nil?
      redirect_to funded_chromebooks_school_path(@school)
    end
  end

  def laptop_types; end
end
