class SchoolToSatConverter
  attr_reader :school, :trust

  def initialize(school)
    @school = school
    @trust = nil
  end

  def convert_to_sat(trust_name: school.name, companies_house_number: nil)
    school.transaction do
      @trust = create_sat_trust(trust_name, companies_house_number)
      school.update!(responsible_body: @trust)
      setup_preorder_information
      setup_std_device_allocation
    end
  end

private

  def create_sat_trust(name, companies_house_number)
    Trust.create!(name: name,
                  companies_house_number: companies_house_number,
                  organisation_type: 'single_academy_trust',
                  who_will_order_devices: 'schools')
  end

  def setup_preorder_information
    if school.preorder_information.nil?
      school.create_preorder_information!(who_will_order_devices: 'school')
    else
      school.preorder_information.update!(who_will_order_devices: 'school')
    end
  end

  def setup_std_device_allocation
    if school.std_device_allocation.nil?
      school.device_allocations.create!(device_type: 'std_device', allocation: 0)
    end
  end
end
