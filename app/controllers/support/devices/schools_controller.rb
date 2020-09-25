class Support::Devices::SchoolsController < Support::BaseController
  def search
    @search_form = BulkUrnSearchForm.new
  end

  def results
    @search_form = BulkUrnSearchForm.new(search_params)
    @schools = @search_form.schools.includes(:preorder_information, :users, responsible_body: :schools)
    @groups = @schools.group_by {|school| SchoolStatus.new(school).status }
    @possible_statuses_and_labels = I18n.t!('activerecord.attributes.school_status.status')
  end

  def show
    @school = School.find_by!(urn: params[:urn])
    @users = @school.users
    @contacts = @school.contacts
  end

  def confirm_invitation
    @school = School.find_by!(urn: params[:school_urn])
    @school_contact = @school.preorder_information&.school_contact
    if @school_contact.nil?
      flash[:warning] = I18n.t('support.schools.invite.no_school_contact', name: @school.name)
      redirect_to support_devices_school_path(@school)
    end
  end

  def invite
    school = School.find_by!(urn: params[:school_urn])
    success = school.invite_school_contact
    if success
      flash[:success] = I18n.t('support.schools.invite.success', name: school.name)
    else
      flash[:warning] = I18n.t('support.schools.invite.failure', name: school.name)
    end
    redirect_to support_devices_responsible_body_path(school.responsible_body)
  end

private

  def search_params
    params.require(:bulk_urn_search_form).permit(:urns)
  end
end
