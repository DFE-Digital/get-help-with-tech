class School::BeforeCanOrderController < School::ChromebooksController
  def edit
    @chromebook_information_form = ChromebookInformationForm.new(
      school: @user.school,
    )
  end

private

  def after_updated_redirect_location
    home_school_path
  end
end
