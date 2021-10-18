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
      rb.who_will_order_devices = 'responsible_body'
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
    @scl_funded_place.can_order!
    @scl_funded_place.update!(raw_laptop_allocation: 50, raw_laptop_cap: 50)
    @scl_funded_place.update!(raw_router_allocation: 50, raw_router_cap: 50)
  end
end
