class School::DonatedDevices::InterestController < School::BaseController
  def new
    @form = DonatedDeviceInterestForm.new
  end

  def create
    @form = DonatedDeviceInterestForm.new(device_interest_params)

    if @form.valid?
      if @form.interested?
        redirect_to about_devices_donated_devices_school_path(@school)
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
          redirect_to what_devices_do_you_want_donated_devices_school_path(@school)
        else
          render :not_interested
        end
      else
        render :interest_confirmation, status: :unprocessable_entity
      end
    end
  end

  def device_types
    @form = DonatedDeviceSelectionForm.new(device_types_params.merge(state: :select_devices))
    if request.post?
      if @form.valid?
        redirect_to how_many_devices_donated_devices_school_path(@school)
      else
        render :device_types, status: :unprocessable_entity
      end
    end
  end

  def how_many_devices
    @form = DonatedDeviceSelectionForm.new(device_types_params.merge(state: :select_units))
    if request.post?
      if @form.valid?
        # redirect_to how_many_devices_donated_devices_school_path(@school)
      else
        render :how_many_devices, status: :unprocessable_entity
      end
    end
  end

private

  def device_interest_params(opts = params)
    opts.fetch(:donated_device_interest_form, {}).permit(:device_interest)
  end

  def device_types_params(opts = params)
    opts.fetch(:donated_device_selection_form, {}).permit(:units, device_types: [])
  end
end
