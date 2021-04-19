class Personas::LaFundedPlace
  def call
    la
    la_funded_place
    la_funded_place_allocation
    la_user
    la_funded_place_user
  end

private

  def la_funded_place
    @la_funded_place ||= la.la_funded_place || la.create_la_funded_place!(name: 'LA funded place') do |s|
      s.urn = (School.maximum(:urn) || 800_000) + 1
      s.address_1 = '14 High Street'
      s.town = 'Cambridge'
      s.county = 'Cambridgeshire'
      s.postcode = 'CB1 0BE'
    end

    @la_funded_place.preorder_information || @la_funded_place.build_preorder_information(who_will_order_devices: 'school').save!

    @la_funded_place
  end

  def la_funded_place_allocation
    @la_funded_place_allocation ||= la_funded_place.std_device_allocation || la_funded_place.create_std_device_allocation!(allocation: 200, cap: 200)
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
end
