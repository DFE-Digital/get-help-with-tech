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

  def la_funded_place
    schools.la_funded_place_establishment_type.first
  end

  def create_la_funded_places!(urn:, device_allocation: 0, router_allocation: 0, extra_args: {})
    return la_funded_place if la_funded_place.present?

    attrs = {
      responsible_body: self,
      urn: urn,
      name: 'State-funded pupils in independent special schools and alternative provision',
      establishment_type: 'la_funded_place',
      address_1: address_1,
      address_2: address_2,
      address_3: address_3,
      town: town,
      county: county,
      postcode: postcode,
    }.reverse_merge(extra_args)

    funded_place = LaFundedPlace.create!(attrs)
    funded_place.create_preorder_information!(who_will_order_devices: 'school')
    funded_place.device_allocations.std_device.create!(allocation: device_allocation)
    funded_place.device_allocations.coms_device.create!(allocation: router_allocation)
    funded_place
  end
end
