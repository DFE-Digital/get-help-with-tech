class Computacenter::SchoolsController < Computacenter::BaseController
  def search
    @search_form = BulkUrnSearchForm.new
  end

  def results
    @search_form = BulkUrnSearchForm.new(search_params)
    @schools = @search_form.schools.includes(:preorder_information, :responsible_body)
  end

  def show
    @school = School.find_by!(urn: params[:urn])
    @users = @school.users.not_deleted
    @contacts = @school.contacts
    @email_audits = @school.email_audits.order(created_at: :desc)
  end

private

  def search_params
    params.require(:bulk_urn_search_form).permit(:urns)
  end
end
