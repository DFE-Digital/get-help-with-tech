class Personas::SclProvisionedUser
  def call
    scl
    scl_funded_place
    scl_user
    scl_funded_place_user
    scl_funded_place_enable_ordering
  end

private

  def scl_funded_place
    @scl_funded_place ||= scl.scl_provision || scl.create_scl_provision!(extra_args: {
      address_1: '30 High Street',
      town: 'Oxford',
      county: 'Oxfordshire',
      postcode: 'OX1 0BE',
    })

    @scl_funded_place
  end

  def scl_funded_place_user
    @scl_funded_place_user ||= scl_funded_place.users.find_or_create_by!(email_address: 'scl.funded.user.1@example.com') do |u|
      u.full_name = 'Jimmy Doe 2'
      u.orders_devices = true
    end
  end

  def scl
    @scl ||= LocalAuthority.find_or_create_by!(name: 'Oxfordshire') do |rb|
      rb.organisation_type = 'county'
      rb.default_who_will_order_devices_for_schools = 'responsible_body'
      rb.gias_id = '874'
    end
  end

  def scl_user
    @scl_user ||= scl.users.find_or_create_by!(email_address: 'scl.user.1@example.com') do |u|
      u.full_name = 'Jane Doe 2'
      u.orders_devices = true
    end

    unless @scl_user.schools.include?(scl_funded_place)
      @scl_user.schools << scl_funded_place
    end

    @scl_user
  end

  def scl_funded_place_enable_ordering
    UpdateSchoolDevicesService.new(school: @scl_funded_place,
                                   state: :can_order,
                                   laptop_allocation: 50,
                                   over_order_reclaimed_laptops: 50,
                                   router_allocation: 50,
                                   over_order_reclaimed_routers: 50)
  end
end
