class ResponsibleBody::DonatedDevices::InterestController < ResponsibleBody::BaseController
  before_action :redirect_if_already_completed, except: %i[all_or_some_schools select_schools opted_in]
  before_action :find_request!, only: %i[select_schools device_types how_many_devices address disclaimer check_answers]

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
    @request = find_or_build_request
    # @form = ResponsibleBody::DonatedDeviceSchoolScopeForm.new(school_scope_params)
    if request.post?
      last_status = @request.status
      @request.assign_attributes(donated_device_params.merge(status: 'opt_in_step'))
      if @request.valid?
        @request.status = last_status
        if @request.opt_in_all_schools?
          # add all schools
          @request.schools = all_centrally_managed_schools_ids
          @request.save!
          # create request now
          # create_request_for_all_schools
          if @request.complete?
            redirect_to responsible_body_donated_devices_opted_in_path
          else
            redirect_to responsible_body_donated_devices_what_devices_do_you_want_path
          end
        else
          @request.save!
          redirect_to responsible_body_donated_devices_select_schools_path
        end
      else
        render :all_or_some_schools, status: :unprocessable_entity
      end
    end
  end

  def select_schools
    if request.post?
      last_status = @request.status
      parms = donated_device_params

      if parms[:opt_in_choice] == 'all_schools'
        parms[:schools] = all_centrally_managed_schools_ids
      else
        parms[:opt_in_choice] = 'some_schools'

        if @request.complete?
          parms[:schools] += @request.schools
        end
      end

      @request.assign_attributes(parms.merge(status: 'schools_step'))
      if @request.valid?
        @request.status = last_status

        if @request.schools_that_have_not_already_been_selected.count.zero?
          @request.opt_in_choice = 'all_schools'
        end

        @request.save!

        if @request.complete?
          redirect_to responsible_body_donated_devices_opted_in_path
        else
          redirect_to responsible_body_donated_devices_what_devices_do_you_want_path
        end
      else
        render :select_schools, status: :unprocessable_entity
      end
    end
  end

  def device_types
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

  def check_answers
    if request.post?
      @request.complete!
      redirect_to responsible_body_donated_devices_opted_in_path
    end
  end

  def opted_in
    @request = present(DonatedDeviceRequest.complete.for_responsible_body(@responsible_body).first)
  end

private

  def create_request_for_all_schools
    ddr = DonatedDeviceRequest.incomplete.for_responsible_body(@responsible_body).first

    school_ids =  all_centrally_managed_schools_ids

    if ddr.nil?
      ddr = DonatedDeviceRequest.create!(schools: school_ids,
                                         responsible_body: @responsible_body,
                                         user: current_user,
                                         opt_in_choice: 'all_schools',
                                         status: 'incomplete')
    else
      ddr.update!(schools: school_ids,
                  user: current_user,
                  opt_in_choice: 'all_schools',
                  status: 'incomplete')
    end
    ddr
  end

  def find_or_build_request
    ddr = DonatedDeviceRequest.for_responsible_body(@responsible_body).first
    ddr = build_donated_device_request if ddr.nil?
    @request = present(ddr)
  end

  def build_donated_device_request
    parms = donated_device_params.merge(responsible_body: @responsible_body,
                                        user: current_user)
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
      # redirect_to responsible_body_donated_devices_opted_in_path if @request.complete?
    end
  end

  def school_scope_params(opts = params)
    opts.fetch(:responsible_body_donated_device_school_scope_form, {}).permit(:scope)
  end

  def device_interest_params(opts = params)
    opts.fetch(:donated_device_interest_form, {}).permit(:device_interest)
  end

  def donated_device_params(opts = params)
    parms = opts.fetch(:donated_device_request, {}).permit(:opt_in_choice, :units, device_types: [], schools: [], opt_in_choice: [])
    parms[:device_types].compact_blank! if parms[:device_types]&.respond_to?(:compact_blank!)
    parms[:schools].compact_blank! if parms[:schools]&.respond_to?(:compact_blank!)
    if parms[:opt_in_choice] && parms[:opt_in_choice]&.respond_to?(:compact_blank)
      parms[:opt_in_choice] = parms[:opt_in_choice].compact_blank.first
    end
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
      redirect_to responsible_body_donated_devices_opted_in_path
    end
  end

  def present(donated_device_request)
    DonatedDeviceRequestPresenter.new(donated_device_request)
  end
end
