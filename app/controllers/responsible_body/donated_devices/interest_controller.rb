class ResponsibleBody::DonatedDevices::InterestController < ResponsibleBody::BaseController
  before_action :redirect_if_already_completed, except: :opted_in
  before_action :find_request!, only: %i[device_types how_many_devices address disclaimer check_answers]

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
          # create request now
          create_request_for_all_schools
          redirect_to responsible_body_donated_devices_what_devices_do_you_want_path
        else
          redirect_to responsible_body_donated_devices_select_schools_path
        end
      else
        render :all_or_some_schools, status: :unprocessable_entity
      end
    end
  end

  def select_schools
  end

  def device_types
    find_request!

    if request.post?
      @request.assign_attributes(donated_device_params.merge(status: 'devices_step'))
      if @request.valid?
        @request.status = 'incomplete'
        @request.save!
        redirect_to responsible_body_donated_devices_how_many_devices_path
      else
        render :device_types, status: :unprocessable_entity
      end
    end
  end

  def how_many_devices
    if request.post?
      @request.assign_attributes(donated_device_params.merge(status: 'units_step'))
      if @request.valid?
        @request.status = 'incomplete'
        @request.save!
        redirect_to responsible_body_donated_devices_address_path
      else
        render :how_many_devices, status: :unprocessable_entity
      end
    end
  end

  def address; end

  def disclaimer; end

private

  def create_request_for_all_schools
    ddr = DonatedDeviceRequest.incomplete.for_responsible_body(@responsible_body).first

    school_ids =  all_centrally_managed_schools_ids

    if ddr.nil?
      ddr = DonatedDeviceRequest.create!(schools: school_ids,
                                         responsible_body: @responsible_body,
                                         user: current_user,
                                         status: 'incomplete')
    else
      ddr.update!(schools: school_ids,
                  user: current_user,
                  status: 'incomplete')
    end
    ddr
  end

  def find_or_build_request
    ddr = DonatedDeviceRequest.incomplete.for_responsible_body(@responsible_body).first
    ddr = build_donated_device_request if ddr.nil?
    @request = present(ddr)
  end

  def build_donated_device_request
    parms = donated_device_params.merge(responsible_body: @responsible_body,
                                        user: current_user,
                                        status: 'incomplete')
    DonatedDeviceRequest.new(parms)
  end

  def find_request!
    ddr = DonatedDeviceRequest.for_responsible_body(@responsible_body).first
    if ddr.nil?
      # send backto beginning if they've got here without a request being saved
      flash[:error] = 'They was a problem with your request'
      redirect_to responsible_body_donated_devices_interest_path
    else
      @request = present(ddr)
      redirect_to opted_in_donated_devices_school_path(@school) if @request.complete?
    end
  end

  def school_scope_params(opts = params)
    opts.fetch(:responsible_body_donated_device_school_scope_form, {}).permit(:scope)
  end

  def device_interest_params(opts = params)
    opts.fetch(:donated_device_interest_form, {}).permit(:device_interest)
  end

  def donated_device_params(opts = params)
    parms = opts.fetch(:donated_device_request, {}).permit(:units, device_types: [], schools: [])
    parms[:device_types].compact_blank! if parms[:device_types]&.respond_to?(:compact_blank!)
    parms[:schools].compact_blank! if parms[:schools]&.respond_to?(:compact_blank!)
    parms
  end

  def all_centrally_managed_schools_ids
    @responsible_body.schools
      .gias_status_open
      .that_are_centrally_managed
      .order(id: :asc)
      .pluck(:id)
  end

  def redirect_if_already_completed
    if DonatedDeviceRequest.complete.for_responsible_body(@responsible_body).any?
      # redirect_to opted_in_donated_devices_school_path(@school)
    end
  end

  def present(donated_device_request)
    DonatedDeviceRequestPresenter.new(donated_device_request)
  end
end
