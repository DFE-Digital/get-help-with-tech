class SchoolToSatConverter
  attr_reader :school, :trust

  def initialize(school)
    @school = school
    @trust = nil
  end

  def convert_to_sat(trust_name: school.name, companies_house_number: nil)
    school.transaction do
      @trust = create_sat_trust(trust_name, companies_house_number)
      setup_std_device_allocation
      school.update!(responsible_body: @trust)
      school.orders_managed_by_school!
    end
  end

private

  def create_sat_trust(name, companies_house_number)
    Trust.create!(name: name,
                  companies_house_number: companies_house_number,
                  organisation_type: 'single_academy_trust',
                  who_will_order_devices: 'school',
                  address_1: school.address_1,
                  address_2: school.address_2,
                  address_3: school.address_3,
                  town: school.town,
                  county: school.county,
                  postcode: school.postcode)
  end

  def setup_std_device_allocation
    if school.std_device_allocation.nil?
      school.device_allocations.create!(device_type: 'std_device', allocation: 0)
    end
  end
end
