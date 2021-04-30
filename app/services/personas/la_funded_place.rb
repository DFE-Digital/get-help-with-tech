class Personas::LaFundedPlace
  def call
    la
    la_funded_place
    la_funded_place_allocation
    la_user
    la_funded_place_user
    la_funded_place_enable_ordering
  end

private

  def la_funded_place
    @la_funded_place ||= la.iss_provision || la.create_iss_provision!(extra_args: {
      address_1: '14 High Street',
      town: 'Cambridge',
      county: 'Cambridgeshire',
      postcode: 'CB1 0BE',
    })

    @la_funded_place
  end

  def la_funded_place_allocation
    @la_funded_place_allocation ||= la_funded_place.std_device_allocation
  end

  def la_funded_place_user
    @la_funded_place_user ||= la_funded_place.users.find_or_create_by!(email_address: 'la.funded.user.1@example.com') do |u|
      u.full_name = 'Jimmy Doe'
      u.orders_devices = true
    end
  end

  def la
    @la ||= LocalAuthority.find_or_create_by!(name: 'Cambridgeshire') do |rb|
      rb.organisation_type = 'county'
      rb.who_will_order_devices = 'responsible_body'
      rb.gias_id = '873'
    end
  end

  def la_user
    @la_user ||= la.users.find_or_create_by!(email_address: 'la.user.1@example.com') do |u|
      u.full_name = 'Jane Doe'
      u.orders_devices = true
    end

    unless @la_user.schools.include?(la_funded_place)
      @la_user.schools << la_funded_place
    end

    @la_user
  end

  def la_funded_place_enable_ordering
    @la_funded_place.can_order!
    @la_funded_place.std_device_allocation.update!(allocation: 100, cap: 100)
    @la_funded_place.coms_device_allocation.update!(allocation: 100, cap: 100)
  end
end
