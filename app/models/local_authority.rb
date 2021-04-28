class LocalAuthority < ResponsibleBody
  enum organisation_type: {
    borough: 'BGH',
    city: 'CIT',
    city_corporation: 'CC',
    combined_authority: 'COMB',
    council_area: 'CA',
    county: 'CTY',
    district: 'DIS',
    london_borough: 'LBO',
    metropolitan_district: 'MD',
    non_metropolitan_district: 'NMD',
    strategic_regional_authority: 'SRA',
    unitary_authority: 'UA',
  }

  validates :organisation_type, presence: true

  has_many :la_funded_provisions, foreign_key: 'responsible_body_id', class_name: 'LaFundedPlace'
  has_one :iss_provision, -> { iss_provision }, foreign_key: 'responsible_body_id', class_name: 'LaFundedPlace'
  has_one :scl_provision, -> { scl_provision }, foreign_key: 'responsible_body_id', class_name: 'LaFundedPlace'

  def create_iss_provision!(device_allocation: 0, router_allocation: 0, extra_args: {})
    create_provision!(urn: "ISS#{gias_id}",
                      name: 'State-funded pupils in independent special schools and alternative provision',
                      provision_type: :iss,
                      device_allocation: device_allocation,
                      router_allocation: router_allocation,
                      extra_args: extra_args)
  end

  def create_scl_provision!(device_allocation: 0, router_allocation: 0, extra_args: {})
    create_provision!(urn: "SCL#{gias_id}",
                      name: 'Care leavers',
                      provision_type: :scl,
                      device_allocation: device_allocation,
                      router_allocation: router_allocation,
                      extra_args: extra_args)
  end

private

  def create_provision!(urn:, name:, provision_type:, device_allocation: 0, router_allocation: 0, extra_args: {})
    existing_provision = la_funded_provisions.find_by(provision_type: provision_type)
    return existing_provision unless existing_provision.nil?

    attrs = {
      responsible_body: self,
      provision_urn: urn,
      name: name,
      provision_type: provision_type,
      establishment_type: 'la_funded_place',
      address_1: address_1,
      address_2: address_2,
      address_3: address_3,
      town: town,
      county: county,
      postcode: postcode,
    }.merge(extra_args)

    provision = LaFundedPlace.create!(attrs)
    provision.create_preorder_information!(who_will_order_devices: 'school')
    provision.device_allocations.std_device.create!(allocation: device_allocation)
    provision.device_allocations.coms_device.create!(allocation: router_allocation)
    add_rb_users_to_provision(provision)
    provision
  end

  def add_rb_users_to_provision(provision)
    users.each { |u| provision.users << u }
  end
end
