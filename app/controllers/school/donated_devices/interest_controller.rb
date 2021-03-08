class School::DonatedDevices::InterestController < School::BaseController
  before_action :redirect_if_already_completed, except: :opted_in
  before_action :find_request!, only: %i[how_many_devices address disclaimer check_answers]

  def new
    @form = DonatedDeviceInterestForm.new
  end

  def create
    @form = DonatedDeviceInterestForm.new(device_interest_params)

    authorize DonatedDeviceInterestForm, policy_class: School::DonatedDevicePolicy

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
      authorize @form, policy_class: School::DonatedDevicePolicy

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
    find_or_build_request

    if request.post?
      authorize @request, policy_class: School::DonatedDevicePolicy

      @request.assign_attributes(donated_device_params)
      if @request.valid?
        @request.save!
        redirect_to how_many_devices_donated_devices_school_path(@school)
      else
        render :device_types, status: :unprocessable_entity
      end
    end
  end

  def how_many_devices
    if request.post?
      authorize @request, policy_class: School::DonatedDevicePolicy
      last_status = @request.status
      @request.assign_attributes(donated_device_params.merge(status: 'units_step'))
      if @request.valid?
        @request.status = last_status
        @request.save!
        redirect_to address_donated_devices_school_path(@school)
      else
        render :how_many_devices, status: :unprocessable_entity
      end
    end
  end

  def address; end

  def disclaimer; end

  def check_answers
    if request.post?
      authorize @request, policy_class: School::DonatedDevicePolicy
      @request.complete!
      redirect_to opted_in_donated_devices_school_path(@school)
    end
  end

  def opted_in
    @request = present(DonatedDeviceRequest.complete.for_school(@school).first)
  end

private

  def find_or_build_request
    ddr = DonatedDeviceRequest.incomplete.for_school(@school).first
    ddr = build_donated_device_request if ddr.nil?
    @request = present(ddr)
  end

  def find_request!
    ddr = DonatedDeviceRequest.for_school(@school).first
    if ddr.nil?
      # send backto beginning if they've got here without a request being saved
      flash[:error] = 'There was a problem with your request'
      redirect_to interest_donated_devices_school_path(@school)
    else
      @request = present(ddr)
      redirect_to opted_in_donated_devices_school_path(@school) if @request.complete?
    end
  end

  def redirect_if_already_completed
    if DonatedDeviceRequest.complete.for_school(@school).any?
      redirect_to opted_in_donated_devices_school_path(@school)
    end
  end

  def build_donated_device_request
    parms = donated_device_params.merge(schools: [@school.id],
                                        user: current_user,
                                        status: 'incomplete')
    DonatedDeviceRequest.new(parms)
  end

  def device_interest_params(opts = params)
    opts.fetch(:donated_device_interest_form, {}).permit(:device_interest)
  end

  def donated_device_params(opts = params)
    parms = opts.fetch(:donated_device_request, {}).permit(:units, device_types: [])
    parms[:device_types].compact_blank! if parms[:device_types]&.respond_to?(:compact_blank!)
    parms
  end

  def present(donated_device_request)
    DonatedDeviceRequestPresenter.new(donated_device_request)
  end
end
