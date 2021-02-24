class Personas::TrustWithSchools
  def call
    trust
    trust_user
    school_one
    school_one_user
  end

private

  def school_one
    @school_one ||= trust.schools.find_or_create_by!(name: 'George School') do |s|
      s.urn = (School.maximum(:urn) || 99_999) + 1
      s.address_1 = '27 Northumberland Street'
      s.town = 'Newcastle'
      s.county = 'Tyne and Wear'
      s.postcode = 'NE1 7DE'
    end

    @school_one.preorder_information || @school_one.build_preorder_information(who_will_order_devices: 'school').save!

    @school_one
  end

  def school_one_user
    @school_one_user ||= school_one.users.find_or_create_by!(email_address: 'school.user.1@example.com') do |u|
      u.full_name = 'Jane Doe'
      u.orders_devices = true
    end
  end

  def trust
    @trust ||= Trust.find_or_create_by!(name: 'Elizabeth Trust') do |rb|
      rb.organisation_type = 'Multi-academy trust'
      rb.in_connectivity_pilot = true
      rb.who_will_order_devices = 'school'
      rb.address_1 = '1 Grey Street'
      rb.town = 'Newcastle'
      rb.county = 'Tyne and Wear'
      rb.postcode = 'NE1 6EE'
    end
  end

  def trust_user
    @trust_user ||= trust.users.find_or_create_by!(email_address: 'trust.user.1@example.com') do |u|
      u.full_name = 'John Doe'
      u.orders_devices = true
    end
  end
end
