class ResponsibleBody::DonatedDevices::InterestController < ResponsibleBody::BaseController
  def new
    @form = DonatedDeviceInterestForm.new
  end

  def create
    @form = DonatedDeviceInterestForm.new(device_interest_params)

    if @form.valid?
      if @form.interested?
        redirect_to responsible_body_donated_devices_about_devices_path(@school)
      else
        render :not_interested
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def about; end

  def queue; end

  def interest_confirmation
    @form = DonatedDeviceInterestForm.new(device_interest_params)
    if request.post?
      if @form.valid?
        if @form.interested?
          redirect_to responsible_body_donated_devices_all_or_some_schools_path
        else
          render :not_interested
        end
      else
        render :interest_confirmation, status: :unprocessable_entity
      end
    end
  end

  def all_or_some_schools
    @form = ResponsibleBody::DonatedDeviceSchoolScopeForm.new(school_scope_params)
    if request.post?
      if @form.valid?
        if @form.all_schools?
          #render 'device_types'
        else
          #render 'select_schools'
        end
      else
        render :all_or_some_schools, status: :unprocessable_entity
      end
    end
  end

private

  def school_scope_params(opts = params)
    opts.fetch(:responsible_body_donated_device_school_scope_form, {}).permit(:scope)
  end

  def device_interest_params(opts = params)
    opts.fetch(:donated_device_interest_form, {}).permit(:device_interest)
  end
end
