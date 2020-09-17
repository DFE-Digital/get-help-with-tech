class Support::Devices::ContactsController < Support::BaseController
  def edit
    @school = School.find_by(urn: params[:school_urn])
    @contact = @school.contacts.find(params[:id])
  end

  def update
    @school = School.find_by(urn: params[:school_urn])
    @contact = @school.contacts.find(params[:id])

    if @contact.update(school_contact_params)
      flash[:success] = 'School contact has been updated'
      redirect_to support_devices_school_path(urn: @school.urn)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def set_as_school_contact
    @school = School.find_by(urn: params[:school_urn])
    @contact = @school.contacts.find(params[:id])

    if @school.preorder_information&.update(school_contact: @contact)
      redirect_to support_devices_school_path(urn: @school.urn)
    end
  end

private

  def school_contact_params
    params.require(:school_contact).permit(:full_name, :email_address, :phone_number)
  end
end
